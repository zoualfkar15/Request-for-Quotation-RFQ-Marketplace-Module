<?php

use yii\db\Migration;

/**
 * Change rfq_request.status from tinyint to string status code.
 *
 * New values:
 * - open
 * - closed
 * - awarded
 * - cancelled
 */
class m260128_000016_change_rfq_request_status_to_string extends Migration
{
    public function safeUp()
    {
        $this->dropIndex('idx_rfq_request_status', '{{%rfq_request}}');

        $this->update('{{%rfq_request}}', ['status' => 'open'], ['status' => 1]);
        $this->update('{{%rfq_request}}', ['status' => 'closed'], ['status' => 2]);
        $this->update('{{%rfq_request}}', ['status' => 'awarded'], ['status' => 3]);
        $this->update('{{%rfq_request}}', ['status' => 'cancelled'], ['status' => 4]);

        $this->alterColumn('{{%rfq_request}}', 'status', $this->string(32)->notNull()->defaultValue('open'));
        $this->createIndex('idx_rfq_request_status', '{{%rfq_request}}', ['status']);
    }

    public function safeDown()
    {
        $this->dropIndex('idx_rfq_request_status', '{{%rfq_request}}');

        $this->update('{{%rfq_request}}', ['status' => 1], ['status' => 'open']);
        $this->update('{{%rfq_request}}', ['status' => 2], ['status' => 'closed']);
        $this->update('{{%rfq_request}}', ['status' => 3], ['status' => 'awarded']);
        $this->update('{{%rfq_request}}', ['status' => 4], ['status' => 'cancelled']);

        $this->alterColumn('{{%rfq_request}}', 'status', $this->tinyInteger()->notNull()->defaultValue(1));
        $this->createIndex('idx_rfq_request_status', '{{%rfq_request}}', ['status']);
    }
}


