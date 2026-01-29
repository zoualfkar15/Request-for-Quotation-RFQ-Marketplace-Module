<?php

use yii\db\Migration;

/**
 * Change offer.status from tinyint to string status code.
 *
 * New values:
 * - active
 * - inactive
 */
class m260128_000017_change_offer_status_to_string extends Migration
{
    public function safeUp()
    {
        $this->dropIndex('idx_offer_status', '{{%offer}}');

        $this->update('{{%offer}}', ['status' => 'active'], ['status' => 1]);
        $this->update('{{%offer}}', ['status' => 'inactive'], ['status' => 0]);

        $this->alterColumn('{{%offer}}', 'status', $this->string(32)->notNull()->defaultValue('active'));
        $this->createIndex('idx_offer_status', '{{%offer}}', ['status']);
    }

    public function safeDown()
    {
        $this->dropIndex('idx_offer_status', '{{%offer}}');

        $this->update('{{%offer}}', ['status' => 1], ['status' => 'active']);
        $this->update('{{%offer}}', ['status' => 0], ['status' => 'inactive']);

        $this->alterColumn('{{%offer}}', 'status', $this->tinyInteger()->notNull()->defaultValue(1));
        $this->createIndex('idx_offer_status', '{{%offer}}', ['status']);
    }
}


