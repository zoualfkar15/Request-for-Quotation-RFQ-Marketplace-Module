<?php

namespace app\models;

use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\web\IdentityInterface;

/**
 * DB-backed user identity (end-users + companies).
 *
 * Table: `user`
 * - role: `user` or `company`
 *
 * @property string|null $phone
 */
class User extends ActiveRecord implements IdentityInterface
{
    public const ROLE_USER = 'user';
    public const ROLE_COMPANY = 'company';
    public const ROLE_ADMIN = 'admin';

    public static function tableName()
    {
        return '{{%user}}';
    }

    public function behaviors()
    {
        return [
            TimestampBehavior::class,
        ];
    }

    public function rules()
    {
        return [
            [['phone'], 'string', 'max' => 40],
            [['phone'], 'filter', 'filter' => static fn($v) => $v === null ? null : trim((string)$v)],
        ];
    }

    public static function findIdentity($id)
    {
        return static::findOne(['id' => $id, 'status' => 10]);
    }

    public static function findIdentityByAccessToken($token, $type = null)
    {
        $payload = \app\components\Jwt::decode($token);
        if (!$payload || empty($payload['sub'])) {
            return null;
        }
        return static::findIdentity((int)$payload['sub']);
    }

    public static function findByUsername($username)
    {
        return static::find()
            ->andWhere(['username' => $username, 'status' => 10])
            ->one();
    }

    public static function findByEmail($email)
    {
        return static::find()
            ->andWhere(['email' => $email, 'status' => 10])
            ->one();
    }

    public function getId()
    {
        return $this->id;
    }

    public function getAuthKey()
    {
        return $this->auth_key;
    }

    public function validateAuthKey($authKey)
    {
        return $this->auth_key === $authKey;
    }

    public function setPassword(string $password): void
    {
        $this->password_hash = Yii::$app->security->generatePasswordHash($password);
    }

    public function validatePassword($password)
    {
        return Yii::$app->security->validatePassword($password, $this->password_hash);
    }

    public function isCompany(): bool
    {
        return $this->role === self::ROLE_COMPANY;
    }

    public function isEndUser(): bool
    {
        return $this->role === self::ROLE_USER;
    }

    public function isAdmin(): bool
    {
        return $this->role === self::ROLE_ADMIN;
    }

    public function isEmailVerified(): bool
    {
        return !empty($this->email_verified_at);
    }

    public function getCategorySubscriptions()
    {
        return $this->hasMany(CategorySubscription::class, ['user_id' => 'id']);
    }

    public function getRfqRequests()
    {
        return $this->hasMany(RfqRequest::class, ['user_id' => 'id']);
    }

    public function getRfqQuotations()
    {
        return $this->hasMany(RfqQuotation::class, ['company_id' => 'id']);
    }
}


