<?php

use yii\db\Migration;

class m260126_000011_seed_default_categories extends Migration
{
    public function safeUp()
    {
        $count = (int)$this->db->createCommand('SELECT COUNT(*) FROM {{%category}}')->queryScalar();
        if ($count > 0) {
            return;
        }

        $now = time();
        $rows = [
            ['name' => 'General Supplies', 'slug' => 'general-supplies', 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'Construction', 'slug' => 'construction', 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'IT & Electronics', 'slug' => 'it-electronics', 'created_at' => $now, 'updated_at' => $now],
        ];

        $this->batchInsert(
            '{{%category}}',
            ['name', 'slug', 'created_at', 'updated_at'],
            array_map(fn($r) => [$r['name'], $r['slug'], $r['created_at'], $r['updated_at']], $rows)
        );
    }

    public function safeDown()
    {
        // Safe to keep categories if already used; do nothing.
        return true;
    }
}


