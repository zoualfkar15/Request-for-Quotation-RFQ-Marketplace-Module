<?php

use yii\db\Migration;

/**
 * Creates `user` table (both end-users and companies).
 */
class m260126_000001_create_user_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%user}}', [
            'id' => $this->primaryKey()->unsigned(),
            'email' => $this->string(190)->notNull()->unique(),
            'username' => $this->string(80)->notNull()->unique(),
            'password_hash' => $this->string(255)->notNull(),
            'auth_key' => $this->string(32)->notNull(),
            'role' => $this->string(20)->notNull(), // user|company
            'company_name' => $this->string(190)->null(),
            'rating' => $this->decimal(3, 2)->notNull()->defaultValue(0.00),
            'status' => $this->tinyInteger()->notNull()->defaultValue(10), // 10 active, 0 inactive
            'created_at' => $this->integer()->notNull(),
            'updated_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_user_role', '{{%user}}', ['role']);
        $this->createIndex('idx_user_status', '{{%user}}', ['status']);
    }

    public function safeDown()
    {
        $this->dropTable('{{%user}}');
    }
}


