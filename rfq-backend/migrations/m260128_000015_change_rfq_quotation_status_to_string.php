<?php

use yii\db\Migration;

/**
 * Change rfq_quotation.status from tinyint to string status code.
 *
 * New values:
 * - created
 * - accepted
 * - rejected_by_user
 * - cancelled_by_company
 */
class m260128_000015_change_rfq_quotation_status_to_string extends Migration
{
    public function safeUp()
    {
        // Drop old status index (will recreate after type change)
        $this->dropIndex('idx_rfq_quotation_status', '{{%rfq_quotation}}');

        // Convert existing values to strings
        $this->update('{{%rfq_quotation}}', ['status' => 'created'], ['status' => 1]);
        $this->update('{{%rfq_quotation}}', ['status' => 'accepted'], ['status' => 2]);
        $this->update('{{%rfq_quotation}}', ['status' => 'rejected_by_user'], ['status' => 3]);
        $this->update('{{%rfq_quotation}}', ['status' => 'cancelled_by_company'], ['status' => 4]);

        // Alter column type
        $this->alterColumn('{{%rfq_quotation}}', 'status', $this->string(32)->notNull()->defaultValue('created'));

        // Recreate index
        $this->createIndex('idx_rfq_quotation_status', '{{%rfq_quotation}}', ['status']);
    }

    public function safeDown()
    {
        $this->dropIndex('idx_rfq_quotation_status', '{{%rfq_quotation}}');

        // Convert strings back to ints
        $this->update('{{%rfq_quotation}}', ['status' => 1], ['status' => 'created']);
        $this->update('{{%rfq_quotation}}', ['status' => 2], ['status' => 'accepted']);
        $this->update('{{%rfq_quotation}}', ['status' => 3], ['status' => 'rejected_by_user']);
        $this->update('{{%rfq_quotation}}', ['status' => 4], ['status' => 'cancelled_by_company']);

        $this->alterColumn('{{%rfq_quotation}}', 'status', $this->tinyInteger()->notNull()->defaultValue(1));
        $this->createIndex('idx_rfq_quotation_status', '{{%rfq_quotation}}', ['status']);
    }
}


