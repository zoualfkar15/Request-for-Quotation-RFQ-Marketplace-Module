<?php

namespace app\models;

use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\helpers\HtmlPurifier;

class Offer extends ActiveRecord
{
    public const STATUS_ACTIVE = 'active';
    public const STATUS_INACTIVE = 'inactive';

    public static function tableName()
    {
        return '{{%offer}}';
    }

    public function behaviors()
    {
        return [
            TimestampBehavior::class,
        ];
    }

    public function rules()
    {
        return [
            [['company_id', 'category_id', 'title', 'description', 'unit', 'price_per_unit'], 'required'],
            [['company_id', 'category_id'], 'integer'],
            [['description'], 'string'],
            [['price_per_unit'], 'number', 'min' => 0],
            [['min_quantity'], 'number', 'min' => 0],
            [['available_from', 'available_until'], 'datetime', 'format' => 'php:Y-m-d H:i:s'],
            [['title'], 'string', 'max' => 190],
            [['unit'], 'string', 'max' => 20],
            [['delivery_city'], 'string', 'max' => 120],
            [['status'], 'string', 'max' => 32],
            [['status'], 'in', 'range' => [self::STATUS_ACTIVE, self::STATUS_INACTIVE]],
            [['category_id'], 'exist', 'targetClass' => Category::class, 'targetAttribute' => ['category_id' => 'id']],
            [['company_id'], 'exist', 'targetClass' => User::class, 'targetAttribute' => ['company_id' => 'id']],

            // Basic XSS hardening: strip dangerous HTML from text inputs.
            [['title'], 'filter', 'filter' => static fn($v) => trim(strip_tags((string)$v))],
            [['description'], 'filter', 'filter' => static fn($v) => HtmlPurifier::process((string)$v, ['HTML.Allowed' => ''])],
        ];
    }

    /**
     * Ensure JSON responses contain correct scalar types (MySQL DECIMAL may come as string).
     */
    public function fields()
    {
        return [
            'id' => fn() => (int)$this->id,
            'company_id' => fn() => (int)$this->company_id,
            'category_id' => fn() => (int)$this->category_id,
            'category_name' => fn() => $this->category ? (string)$this->category->name : null,
            'category_slug' => fn() => $this->category ? (string)$this->category->slug : null,
            'title' => fn() => (string)$this->title,
            'description' => fn() => (string)$this->description,
            'unit' => fn() => (string)$this->unit,
            'min_quantity' => fn() => $this->min_quantity === null ? null : (float)$this->min_quantity,
            'price_per_unit' => fn() => (float)$this->price_per_unit,
            'delivery_city' => fn() => $this->delivery_city === null ? null : (string)$this->delivery_city,
            'available_from' => fn() => $this->available_from === null ? null : (string)$this->available_from,
            'available_until' => fn() => $this->available_until === null ? null : (string)$this->available_until,
            'status' => fn() => (string)$this->status,
            'created_at' => fn() => (int)$this->created_at,
            'updated_at' => fn() => (int)$this->updated_at,
        ];
    }

    public function getCompany()
    {
        return $this->hasOne(User::class, ['id' => 'company_id']);
    }

    public function getCategory()
    {
        return $this->hasOne(Category::class, ['id' => 'category_id']);
    }
}


