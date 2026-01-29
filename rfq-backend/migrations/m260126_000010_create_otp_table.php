<?php

use yii\db\Migration;

class m260126_000010_create_otp_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%otp}}', [
            'id' => $this->primaryKey()->unsigned(),
            'user_id' => $this->integer()->unsigned()->null(),
            'email' => $this->string(190)->notNull(),
            'purpose' => $this->string(20)->notNull(), // verify|reset
            'code_hash' => $this->string(64)->notNull(), // sha256 hex
            'expires_at' => $this->integer()->notNull(),
            'last_sent_at' => $this->integer()->notNull(),
            'used_at' => $this->integer()->null(),
            'created_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_otp_email_purpose', '{{%otp}}', ['email', 'purpose', 'created_at']);
        $this->createIndex('idx_otp_user', '{{%otp}}', ['user_id']);
        $this->createIndex('idx_otp_expires', '{{%otp}}', ['expires_at']);
        $this->addForeignKey('fk_otp_user', '{{%otp}}', 'user_id', '{{%user}}', 'id', 'SET NULL', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%otp}}');
    }
}


