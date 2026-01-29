<?php

namespace app\models;

use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\helpers\HtmlPurifier;

class RfqRequest extends ActiveRecord
{
    public const STATUS_OPEN = 'open';
    public const STATUS_CLOSED = 'closed';
    public const STATUS_AWARDED = 'awarded';
    public const STATUS_CANCELLED = 'cancelled';

    public static function tableName()
    {
        return '{{%rfq_request}}';
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
            [['user_id', 'category_id', 'title', 'description', 'quantity', 'unit', 'delivery_city', 'required_delivery_date', 'expires_at'], 'required'],
            [['user_id', 'category_id', 'awarded_quotation_id'], 'integer'],
            [['description'], 'string'],
            [['quantity'], 'number', 'min' => 0.001],
            [['budget_min', 'budget_max', 'delivery_lat', 'delivery_lng'], 'number'],
            [['required_delivery_date'], 'date', 'format' => 'php:Y-m-d'],
            [['expires_at'], 'datetime', 'format' => 'php:Y-m-d H:i:s'],
            [['title'], 'string', 'max' => 190],
            [['unit'], 'string', 'max' => 20],
            [['delivery_city'], 'string', 'max' => 120],
            [['status'], 'string', 'max' => 32],
            [['status'], 'in', 'range' => [self::STATUS_OPEN, self::STATUS_CLOSED, self::STATUS_AWARDED, self::STATUS_CANCELLED]],
            ['budget_max', 'compare', 'compareAttribute' => 'budget_min', 'operator' => '>=', 'type' => 'number', 'when' => fn() => $this->budget_min !== null && $this->budget_max !== null],
            [['category_id'], 'exist', 'targetClass' => Category::class, 'targetAttribute' => ['category_id' => 'id']],
            [['user_id'], 'exist', 'targetClass' => User::class, 'targetAttribute' => ['user_id' => 'id']],

            // Basic XSS hardening for stored text.
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
            'user_id' => fn() => (int)$this->user_id,
            'category_id' => fn() => (int)$this->category_id,
            'title' => fn() => (string)$this->title,
            'description' => fn() => (string)$this->description,
            'quantity' => fn() => (float)$this->quantity,
            'unit' => fn() => (string)$this->unit,
            'delivery_city' => fn() => (string)$this->delivery_city,
            'delivery_lat' => fn() => $this->delivery_lat === null ? null : (float)$this->delivery_lat,
            'delivery_lng' => fn() => $this->delivery_lng === null ? null : (float)$this->delivery_lng,
            'required_delivery_date' => fn() => (string)$this->required_delivery_date,
            'budget_min' => fn() => $this->budget_min === null ? null : (float)$this->budget_min,
            'budget_max' => fn() => $this->budget_max === null ? null : (float)$this->budget_max,
            'expires_at' => fn() => (string)$this->expires_at,
            'status' => fn() => (string)$this->status,
            'awarded_quotation_id' => fn() => $this->awarded_quotation_id === null ? null : (int)$this->awarded_quotation_id,
            'created_at' => fn() => (int)$this->created_at,
            'updated_at' => fn() => (int)$this->updated_at,
        ];
    }

    public function getUser()
    {
        return $this->hasOne(User::class, ['id' => 'user_id']);
    }

    public function getCategory()
    {
        return $this->hasOne(Category::class, ['id' => 'category_id']);
    }

    public function getQuotations()
    {
        return $this->hasMany(RfqQuotation::class, ['request_id' => 'id']);
    }

    public function getAwardedQuotation()
    {
        return $this->hasOne(RfqQuotation::class, ['id' => 'awarded_quotation_id']);
    }
}


