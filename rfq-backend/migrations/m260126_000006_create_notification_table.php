<?php

use yii\db\Migration;

class m260126_000006_create_notification_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%notification}}', [
            'id' => $this->primaryKey()->unsigned(),
            'recipient_user_id' => $this->integer()->unsigned()->notNull(),
            'type' => $this->string(60)->notNull(),
            'payload_json' => $this->text()->notNull(),
            'is_read' => $this->tinyInteger()->notNull()->defaultValue(0),
            'created_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_notification_recipient', '{{%notification}}', ['recipient_user_id', 'created_at']);
        $this->addForeignKey('fk_notification_recipient', '{{%notification}}', 'recipient_user_id', '{{%user}}', 'id', 'CASCADE', 'CASCADE');
    }

    public function safeDown()
    {
        $this->dropTable('{{%notification}}');
    }
}


