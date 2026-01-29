<?php

use yii\db\Migration;

class m260126_000002_create_category_table extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%category}}', [
            'id' => $this->primaryKey()->unsigned(),
            'name' => $this->string(120)->notNull(),
            'slug' => $this->string(140)->notNull()->unique(),
            'created_at' => $this->integer()->notNull(),
            'updated_at' => $this->integer()->notNull(),
        ]);

        $this->createIndex('idx_category_name', '{{%category}}', ['name']);
    }

    public function safeDown()
    {
        $this->dropTable('{{%category}}');
    }
}


