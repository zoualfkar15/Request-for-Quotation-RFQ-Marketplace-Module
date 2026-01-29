<?php

namespace app\modules\api\controllers;

use app\components\Jwt;
use app\models\User;
use Yii;
use yii\web\UnauthorizedHttpException;

/**
 * Provides Centrifugo connection token for authenticated users.
 */
class WsController extends BaseApiController
{
    /**
     * GET /api/ws/token
     */
    public function actionToken()
    {
        /** @var User|null $user */
        $user = Yii::$app->user->identity;
        if (!$user) {
            throw new UnauthorizedHttpException('Unauthorized.');
        }

        $ttl = (int)(Yii::$app->params['centrifugoJwtTtlSeconds'] ?? (60 * 60 * 24));
        $secret = (string)(Yii::$app->params['centrifugoJwtSecret'] ?? '');
        $now = time();

        $token = Jwt::encode([
            'sub' => (string)$user->id,
            'iat' => $now,
            'exp' => $now + $ttl,
        ], $secret);

        return [
            'token' => $token,
            'expires_in' => $ttl,
            'user_id' => (int)$user->id,
        ];
    }
}


