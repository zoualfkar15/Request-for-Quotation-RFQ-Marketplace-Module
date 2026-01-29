<?php

namespace app\models;

use yii\db\ActiveRecord;

class RefreshToken extends ActiveRecord
{
    public static function tableName()
    {
        return '{{%refresh_token}}';
    }

    public function rules()
    {
        return [
            [['user_id', 'token_hash', 'expires_at', 'created_at'], 'required'],
            [['user_id', 'expires_at', 'revoked_at', 'created_at'], 'integer'],
            [['token_hash'], 'string', 'max' => 64],
            [['token_hash'], 'unique'],
            [['user_id'], 'exist', 'targetClass' => User::class, 'targetAttribute' => ['user_id' => 'id']],
        ];
    }

    public static function hash(string $token): string
    {
        return hash('sha256', $token);
    }

    public function isActive(): bool
    {
        if ($this->revoked_at !== null) {
            return false;
        }
        return (int)$this->expires_at > time();
    }
}


