<?php

use yii\db\Migration;

class m260126_000007_create_offer_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%offer}}', [
            'id' => $this->primaryKey()->unsigned(),
            'company_id' => $this->integer()->unsigned()->notNull(),
            'category_id' => $this->integer()->unsigned()->notNull(),
            'title' => $this->string(190)->notNull(),
            'description' => $this->text()->notNull(),
            'unit' => $this->string(20)->notNull(),
            'min_quantity' => $this->decimal(12, 3)->null(),
            'price_per_unit' => $this->decimal(12, 2)->notNull(),
            'delivery_city' => $this->string(120)->null(),
            'available_from' => $this->dateTime()->null(),
            'available_until' => $this->dateTime()->null(),
            'status' => $this->tinyInteger()->notNull()->defaultValue(1), // 1 active, 0 inactive
            'created_at' => $this->integer()->notNull(),
            'updated_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_offer_company', '{{%offer}}', ['company_id']);
        $this->createIndex('idx_offer_category', '{{%offer}}', ['category_id']);
        $this->createIndex('idx_offer_status', '{{%offer}}', ['status']);
        $this->createIndex('idx_offer_available_until', '{{%offer}}', ['available_until']);

        $this->addForeignKey('fk_offer_company', '{{%offer}}', 'company_id', '{{%user}}', 'id', 'CASCADE', 'CASCADE');
        $this->addForeignKey('fk_offer_category', '{{%offer}}', 'category_id', '{{%category}}', 'id', 'RESTRICT', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%offer}}');
    }
}


