<?php

namespace app\models;

use yii\db\ActiveRecord;

class Otp extends ActiveRecord
{
    public const PURPOSE_VERIFY = 'verify';
    public const PURPOSE_RESET = 'reset';

    public static function tableName()
    {
        return '{{%otp}}';
    }

    public function rules()
    {
        return [
            [['email', 'purpose', 'code_hash', 'expires_at', 'last_sent_at', 'created_at'], 'required'],
            [['user_id', 'expires_at', 'last_sent_at', 'used_at', 'created_at'], 'integer'],
            [['email'], 'string', 'max' => 190],
            [['purpose'], 'string', 'max' => 20],
            [['code_hash'], 'string', 'max' => 64],
            [['purpose'], 'in', 'range' => [self::PURPOSE_VERIFY, self::PURPOSE_RESET]],
        ];
    }

    public static function hashCode(string $code): string
    {
        return hash('sha256', $code);
    }

    public function isExpired(): bool
    {
        return (int)$this->expires_at < time();
    }

    public function isUsed(): bool
    {
        return $this->used_at !== null;
    }
}


