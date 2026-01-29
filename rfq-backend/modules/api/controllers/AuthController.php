<?php

namespace app\modules\api\controllers;

use app\components\Jwt;
use app\models\Otp;
use app\models\RefreshToken;
use app\models\User;
use Yii;
use yii\web\BadRequestHttpException;
use yii\web\ForbiddenHttpException;
use yii\web\UnauthorizedHttpException;

class AuthController extends BaseApiController
{
    public function behaviors()
    {
        $behaviors = parent::behaviors();
        $behaviors['authenticator']['except'] = ['options', 'login', 'register', 'refresh', 'otp-send', 'otp-verify', 'password-reset'];
        return $behaviors;
    }

    public function actionRegister()
    {
        $body = Yii::$app->request->getBodyParams();

        $role = $body['role'] ?? User::ROLE_USER;
        if (!in_array($role, [User::ROLE_USER, User::ROLE_COMPANY], true)) {
            throw new BadRequestHttpException('Invalid role.');
        }

        $email = trim((string)($body['email'] ?? ''));
        $username = trim((string)($body['username'] ?? ''));
        $password = (string)($body['password'] ?? '');
        $companyName = trim((string)($body['company_name'] ?? ''));
        $phone = trim((string)($body['phone'] ?? ''));

        if ($email === '' || $username === '' || $password === '') {
            throw new BadRequestHttpException('email, username and password are required.');
        }
        if ($role === User::ROLE_COMPANY && $companyName === '') {
            throw new BadRequestHttpException('company_name is required for company accounts.');
        }
        if ($role === User::ROLE_COMPANY && $phone === '') {
            throw new BadRequestHttpException('phone is required for company accounts.');
        }
        if (User::findByEmail($email) || User::findByUsername($username)) {
            throw new BadRequestHttpException('User already exists.');
        }

        $user = new User();
        $user->email = $email;
        $user->username = $username;
        $user->role = $role;
        $user->company_name = $role === User::ROLE_COMPANY ? $companyName : null;
        $user->phone = $role === User::ROLE_COMPANY ? $phone : null;
        $user->auth_key = Yii::$app->security->generateRandomString(32);
        $user->setPassword($password);
        $user->status = 10;

        if (!$user->save()) {
            Yii::error($user->errors, __METHOD__);
            throw new BadRequestHttpException('Unable to register user.');
        }

        // Issue verification OTP (fixed code for assessment)
        $otpCode = $this->issueOtp($user->email, Otp::PURPOSE_VERIFY, $user->id);

        return $this->issueTokensResponse($user) + [
            'requires_verification' => true,
            // For assessment/testing convenience (OTP is fixed anyway)
            'otp_code' => $otpCode,
        ];
    }

    public function actionLogin()
    {
        $body = Yii::$app->request->getBodyParams();
        $login = trim((string)($body['login'] ?? '')); // username or email
        $password = (string)($body['password'] ?? '');

        if ($login === '' || $password === '') {
            throw new BadRequestHttpException('login and password are required.');
        }

        $user = filter_var($login, FILTER_VALIDATE_EMAIL) ? User::findByEmail($login) : User::findByUsername($login);
        if (!$user || !$user->validatePassword($password)) {
            throw new UnauthorizedHttpException('Invalid credentials.');
        }
        if (!$user->isEmailVerified()) {
            // Auto-issue verification OTP on login attempt (assessment-friendly).
            $otpCode = null;
            $retryIn = null;
            try {
                $otpCode = $this->issueOtp($user->email, Otp::PURPOSE_VERIFY, (int)$user->id);
            } catch (BadRequestHttpException $e) {
                // Throttled (1 minute). Keep response as 403 but include retry_in if we can parse it.
                if (preg_match('/Retry in (\d+)s/', $e->getMessage(), $m)) {
                    $retryIn = (int)$m[1];
                }
            }

            Yii::$app->response->statusCode = 403;
            return [
                'message' => 'Account not verified. OTP sent. Please verify your email with OTP.',
                'requires_verification' => true,
                'otp_code' => $otpCode ?? '123456',
                'retry_in' => $retryIn,
            ];
        }

        return $this->issueTokensResponse($user);
    }

    public function actionMe()
    {
        /** @var User|null $user */
        $user = Yii::$app->user->identity;
        if (!$user) {
            throw new UnauthorizedHttpException('Unauthorized.');
        }
        return [
            'user' => $this->serializeUser($user),
        ];
    }

    /**
     * Refresh access token using refresh token (rotation).
     * Body: { "refresh_token": "..." }
     */
    public function actionRefresh()
    {
        $body = Yii::$app->request->getBodyParams();
        $refreshToken = (string)($body['refresh_token'] ?? '');
        if ($refreshToken === '') {
            throw new BadRequestHttpException('refresh_token is required.');
        }

        $tokenHash = RefreshToken::hash($refreshToken);
        $row = RefreshToken::findOne(['token_hash' => $tokenHash]);
        if (!$row || !$row->isActive()) {
            throw new UnauthorizedHttpException('Invalid refresh token.');
        }

        $user = User::findIdentity((int)$row->user_id);
        if (!$user) {
            throw new UnauthorizedHttpException('Invalid refresh token.');
        }

        // Rotate refresh token
        $row->revoked_at = time();
        $row->save(false, ['revoked_at']);

        return $this->issueTokensResponse($user);
    }

    /**
     * Logout by revoking refresh token (or all refresh tokens).
     * Body: { "refresh_token": "..." } or { "all": true }
     */
    public function actionLogout()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user) {
            throw new UnauthorizedHttpException('Unauthorized.');
        }

        $body = Yii::$app->request->getBodyParams();
        $all = (bool)($body['all'] ?? false);
        $now = time();

        if ($all) {
            RefreshToken::updateAll(['revoked_at' => $now], ['and', ['user_id' => (int)$user->id], ['revoked_at' => null]]);
            return ['ok' => true];
        }

        $refreshToken = (string)($body['refresh_token'] ?? '');
        if ($refreshToken === '') {
            throw new BadRequestHttpException('refresh_token is required (or pass all=true).');
        }

        $tokenHash = RefreshToken::hash($refreshToken);
        $row = RefreshToken::findOne(['token_hash' => $tokenHash, 'user_id' => (int)$user->id]);
        if ($row && $row->revoked_at === null) {
            $row->revoked_at = $now;
            $row->save(false, ['revoked_at']);
        }

        return ['ok' => true];
    }

    /**
     * Send OTP (fixed code 123456) for verify or reset.
     * Body: { "email": "...", "purpose": "verify"|"reset" }
     *
     * Throttle: 1 minute between sends per (email,purpose).
     */
    public function actionOtpSend()
    {
        $body = Yii::$app->request->getBodyParams();
        $email = trim((string)($body['email'] ?? ''));
        $purpose = (string)($body['purpose'] ?? '');

        if ($email === '' || !in_array($purpose, [Otp::PURPOSE_VERIFY, Otp::PURPOSE_RESET], true)) {
            throw new BadRequestHttpException('email and valid purpose are required.');
        }

        $user = User::findByEmail($email);
        if ($purpose === Otp::PURPOSE_VERIFY) {
            if (!$user) {
                throw new BadRequestHttpException('User not found.');
            }
            if ($user->isEmailVerified()) {
                return ['ok' => true, 'message' => 'Already verified.'];
            }
        }
        if ($purpose === Otp::PURPOSE_RESET && !$user) {
            // Avoid leaking whether email exists; still return ok.
            $otpCode = $this->issueOtp($email, $purpose, null);
            return ['ok' => true, 'otp_code' => $otpCode];
        }

        $otpCode = $this->issueOtp($email, $purpose, $user ? (int)$user->id : null);
        return ['ok' => true, 'otp_code' => $otpCode];
    }

    /**
     * Verify OTP.
     * Body: { "email": "...", "purpose": "verify"|"reset", "code": "123456" }
     */
    public function actionOtpVerify()
    {
        $body = Yii::$app->request->getBodyParams();
        $email = trim((string)($body['email'] ?? ''));
        $purpose = (string)($body['purpose'] ?? '');
        $code = (string)($body['code'] ?? '');

        if ($email === '' || $code === '' || !in_array($purpose, [Otp::PURPOSE_VERIFY, Otp::PURPOSE_RESET], true)) {
            throw new BadRequestHttpException('email, code and valid purpose are required.');
        }

        $otp = Otp::find()
            ->where(['email' => $email, 'purpose' => $purpose])
            ->andWhere(['used_at' => null])
            ->orderBy(['id' => SORT_DESC])
            ->one();

        if (!$otp || $otp->isExpired()) {
            throw new BadRequestHttpException('OTP expired or not found.');
        }

        if (!hash_equals($otp->code_hash, Otp::hashCode($code))) {
            throw new BadRequestHttpException('Invalid OTP.');
        }

        $otp->used_at = time();
        $otp->save(false, ['used_at']);

        if ($purpose === Otp::PURPOSE_VERIFY) {
            $user = User::findByEmail($email);
            if (!$user) {
                throw new BadRequestHttpException('User not found.');
            }
            if (!$user->isEmailVerified()) {
                $user->email_verified_at = time();
                $user->save(false, ['email_verified_at', 'updated_at']);
            }

            // Return tokens like login (so mobile can continue to Home directly)
            return $this->issueTokensResponse($user);
        }

        return ['ok' => true];
    }

    /**
     * Reset password using OTP.
     * Body: { "email": "...", "code": "123456", "new_password": "..." }
     */
    public function actionPasswordReset()
    {
        $body = Yii::$app->request->getBodyParams();
        $email = trim((string)($body['email'] ?? ''));
        $code = (string)($body['code'] ?? '');
        $newPassword = (string)($body['new_password'] ?? '');

        if ($email === '' || $code === '' || $newPassword === '') {
            throw new BadRequestHttpException('email, code and new_password are required.');
        }

        // verify OTP with purpose reset
        $otp = Otp::find()
            ->where(['email' => $email, 'purpose' => Otp::PURPOSE_RESET])
            ->andWhere(['used_at' => null])
            ->orderBy(['id' => SORT_DESC])
            ->one();

        if (!$otp || $otp->isExpired()) {
            throw new BadRequestHttpException('OTP expired or not found.');
        }
        if (!hash_equals($otp->code_hash, Otp::hashCode($code))) {
            throw new BadRequestHttpException('Invalid OTP.');
        }

        $user = User::findByEmail($email);
        if (!$user) {
            // Avoid leaking whether email exists
            return ['ok' => true];
        }

        $user->setPassword($newPassword);
        $user->save(false, ['password_hash', 'updated_at']);

        $otp->used_at = time();
        $otp->save(false, ['used_at']);

        // Revoke existing refresh tokens for safety
        RefreshToken::updateAll(['revoked_at' => time()], ['and', ['user_id' => (int)$user->id], ['revoked_at' => null]]);

        return ['ok' => true];
    }

    private function issueAccessToken(User $user): string
    {
        $ttl = (int)(Yii::$app->params['jwtTtlSeconds'] ?? (60 * 60 * 24 * 7));
        $now = time();

        return Jwt::encode([
            'sub' => (int)$user->id,
            'role' => (string)$user->role,
            'iat' => $now,
            'exp' => $now + $ttl,
        ]);
    }

    private function issueTokensResponse(User $user): array
    {
        $accessTtl = (int)(Yii::$app->params['jwtTtlSeconds'] ?? (60 * 60 * 24 * 7));
        $refreshTtl = (int)(Yii::$app->params['refreshTokenTtlSeconds'] ?? (60 * 60 * 24 * 30));
        $now = time();

        $refreshToken = Yii::$app->security->generateRandomString(64);
        $rt = new RefreshToken([
            'user_id' => (int)$user->id,
            'token_hash' => RefreshToken::hash($refreshToken),
            'expires_at' => $now + $refreshTtl,
            'created_at' => $now,
        ]);
        $rt->save(false);

        return [
            'access_token' => $this->issueAccessToken($user),
            'expires_in' => $accessTtl,
            'refresh_token' => $refreshToken,
            'refresh_expires_in' => $refreshTtl,
            'user' => $this->serializeUser($user),
        ];
    }

    private function issueOtp(string $email, string $purpose, ?int $userId): string
    {
        $now = time();

        // Throttle: 60s per (email,purpose)
        $last = Otp::find()
            ->where(['email' => $email, 'purpose' => $purpose])
            ->orderBy(['id' => SORT_DESC])
            ->one();
        if ($last && (int)$last->last_sent_at + 60 > $now) {
            $retryIn = ((int)$last->last_sent_at + 60) - $now;
            throw new BadRequestHttpException('Please wait before requesting a new OTP. Retry in ' . $retryIn . 's.');
        }

        $code = '123456';
        $ttl = 10 * 60; // 10 minutes

        $otp = new Otp([
            'user_id' => $userId,
            'email' => $email,
            'purpose' => $purpose,
            'code_hash' => Otp::hashCode($code),
            'expires_at' => $now + $ttl,
            'last_sent_at' => $now,
            'created_at' => $now,
        ]);
        $otp->save(false);

        return $code;
    }

    private function serializeUser(User $user): array
    {
        $phone = $user->getAttribute('phone');
        return [
            'id' => (int)$user->id,
            'email' => (string)$user->email,
            'username' => (string)$user->username,
            'role' => (string)$user->role,
            'company_name' => $user->company_name ? (string)$user->company_name : null,
            'phone' => $phone ? (string)$phone : null,
            'rating' => (float)$user->rating,
            'email_verified' => (bool)$user->isEmailVerified(),
        ];
    }
}


