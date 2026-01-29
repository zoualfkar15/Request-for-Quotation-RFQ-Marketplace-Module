<?php

use yii\db\Migration;

class m260126_000008_create_refresh_token_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%refresh_token}}', [
            'id' => $this->primaryKey()->unsigned(),
            'user_id' => $this->integer()->unsigned()->notNull(),
            'token_hash' => $this->string(64)->notNull()->unique(), // sha256 hex
            'expires_at' => $this->integer()->notNull(),
            'revoked_at' => $this->integer()->null(),
            'created_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_refresh_token_user', '{{%refresh_token}}', ['user_id', 'created_at']);
        $this->createIndex('idx_refresh_token_expires', '{{%refresh_token}}', ['expires_at']);
        $this->addForeignKey('fk_refresh_token_user', '{{%refresh_token}}', 'user_id', '{{%user}}', 'id', 'CASCADE', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%refresh_token}}');
    }
}


