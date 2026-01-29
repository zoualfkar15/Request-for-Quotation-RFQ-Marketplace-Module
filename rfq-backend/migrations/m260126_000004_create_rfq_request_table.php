<?php

use yii\db\Migration;

class m260126_000004_create_rfq_request_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%rfq_request}}', [
            'id' => $this->primaryKey()->unsigned(),
            'user_id' => $this->integer()->unsigned()->notNull(),
            'category_id' => $this->integer()->unsigned()->notNull(),
            'title' => $this->string(190)->notNull(),
            'description' => $this->text()->notNull(),
            'quantity' => $this->decimal(12, 3)->notNull(),
            'unit' => $this->string(20)->notNull(),
            'delivery_city' => $this->string(120)->notNull(),
            'delivery_lat' => $this->decimal(10, 7)->null(),
            'delivery_lng' => $this->decimal(10, 7)->null(),
            'required_delivery_date' => $this->date()->notNull(),
            'budget_min' => $this->decimal(12, 2)->null(),
            'budget_max' => $this->decimal(12, 2)->null(),
            'expires_at' => $this->dateTime()->notNull(),
            'status' => $this->tinyInteger()->notNull()->defaultValue(1), // 1 open, 2 closed, 3 awarded, 4 cancelled
            'awarded_quotation_id' => $this->integer()->unsigned()->null(), // FK added after quotation table exists
            'created_at' => $this->integer()->notNull(),
            'updated_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_rfq_request_user', '{{%rfq_request}}', ['user_id']);
        $this->createIndex('idx_rfq_request_category', '{{%rfq_request}}', ['category_id']);
        $this->createIndex('idx_rfq_request_status', '{{%rfq_request}}', ['status']);
        $this->createIndex('idx_rfq_request_expires', '{{%rfq_request}}', ['expires_at']);

        $this->addForeignKey('fk_rfq_request_user', '{{%rfq_request}}', 'user_id', '{{%user}}', 'id', 'CASCADE', 'CASCADE');
        $this->addForeignKey('fk_rfq_request_category', '{{%rfq_request}}', 'category_id', '{{%category}}', 'id', 'RESTRICT', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%rfq_request}}');
    }
}


