<?php

use yii\db\Migration;

class m260126_000003_create_category_subscription_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%category_subscription}}', [
            'id' => $this->primaryKey()->unsigned(),
            'user_id' => $this->integer()->unsigned()->notNull(),
            'category_id' => $this->integer()->unsigned()->notNull(),
            'created_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('uidx_category_subscription_user_category', '{{%category_subscription}}', ['user_id', 'category_id'], true);
        $this->createIndex('idx_category_subscription_category', '{{%category_subscription}}', ['category_id']);

        $this->addForeignKey('fk_category_subscription_user', '{{%category_subscription}}', 'user_id', '{{%user}}', 'id', 'CASCADE', 'CASCADE');
        $this->addForeignKey('fk_category_subscription_category', '{{%category_subscription}}', 'category_id', '{{%category}}', 'id', 'CASCADE', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%category_subscription}}');
    }
}


