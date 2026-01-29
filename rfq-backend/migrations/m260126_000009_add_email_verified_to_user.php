<?php

use yii\db\Migration;

class m260126_000009_add_email_verified_to_user extends Migration
{
    public function safeUp()
    {
        $this->addColumn('{{%user}}', 'email_verified_at', $this->integer()->null()->after('updated_at'));
        $this->createIndex('idx_user_email_verified', '{{%user}}', ['email_verified_at']);
    }

    public function safeDown()
    {
        $this->dropIndex('idx_user_email_verified', '{{%user}}');
        $this->dropColumn('{{%user}}', 'email_verified_at');
    }
}


