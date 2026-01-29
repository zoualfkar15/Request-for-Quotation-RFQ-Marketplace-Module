<?php

use yii\db\Migration;

class m260126_000005_create_rfq_quotation_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%rfq_quotation}}', [
            'id' => $this->primaryKey()->unsigned(),
            'request_id' => $this->integer()->unsigned()->notNull(),
            'company_id' => $this->integer()->unsigned()->notNull(),
            'price_per_unit' => $this->decimal(12, 2)->notNull(),
            'total_price' => $this->decimal(12, 2)->notNull(),
            'delivery_time_days' => $this->integer()->unsigned()->notNull(),
            'delivery_cost' => $this->decimal(12, 2)->notNull()->defaultValue(0),
            'payment_terms' => $this->string(255)->notNull(),
            'notes' => $this->text()->null(),
            'valid_until' => $this->dateTime()->notNull(),
            'status' => $this->tinyInteger()->notNull()->defaultValue(1), // 1 pending, 2 accepted, 3 rejected, 4 withdrawn
            'created_at' => $this->integer()->notNull(),
            'updated_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_rfq_quotation_request', '{{%rfq_quotation}}', ['request_id']);
        $this->createIndex('idx_rfq_quotation_company', '{{%rfq_quotation}}', ['company_id']);
        $this->createIndex('idx_rfq_quotation_status', '{{%rfq_quotation}}', ['status']);
        $this->createIndex('uidx_rfq_quotation_request_company', '{{%rfq_quotation}}', ['request_id', 'company_id'], true);

        $this->addForeignKey('fk_rfq_quotation_request', '{{%rfq_quotation}}', 'request_id', '{{%rfq_request}}', 'id', 'CASCADE', 'CASCADE');
        $this->addForeignKey('fk_rfq_quotation_company', '{{%rfq_quotation}}', 'company_id', '{{%user}}', 'id', 'CASCADE', 'CASCADE');

        // Award reference (now that quotation table exists)
        $this->addForeignKey('fk_rfq_request_awarded_quotation', '{{%rfq_request}}', 'awarded_quotation_id', '{{%rfq_quotation}}', 'id', 'SET NULL', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%rfq_quotation}}');
    }
}


