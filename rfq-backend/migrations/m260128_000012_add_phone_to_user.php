<?php

use yii\db\Migration;

/**
 * Adds `phone` column to `user` table (mainly for company contact).
 */
class m260128_000012_add_phone_to_user extends Migration
{
    public function safeUp()
    {
        $this->addColumn('{{%user}}', 'phone', $this->string(40)->null()->after('company_name'));
        $this->createIndex('idx_user_phone', '{{%user}}', ['phone']);
    }

    public function safeDown()
    {
        $this->dropIndex('idx_user_phone', '{{%user}}');
        $this->dropColumn('{{%user}}', 'phone');
    }
}


