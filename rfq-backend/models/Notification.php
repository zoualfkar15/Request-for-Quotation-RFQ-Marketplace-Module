<?php

namespace app\models;

use yii\db\ActiveRecord;

class Notification extends ActiveRecord
{
    public static function tableName()
    {
        return '{{%notification}}';
    }

    public function rules()
    {
        return [
            [['recipient_user_id', 'type', 'payload_json'], 'required'],
            [['recipient_user_id', 'is_read', 'created_at'], 'integer'],
            [['payload_json'], 'string'],
            [['type'], 'string', 'max' => 60],
            [['recipient_user_id'], 'exist', 'targetClass' => User::class, 'targetAttribute' => ['recipient_user_id' => 'id']],
        ];
    }

    public function getRecipient()
    {
        return $this->hasOne(User::class, ['id' => 'recipient_user_id']);
    }
}


