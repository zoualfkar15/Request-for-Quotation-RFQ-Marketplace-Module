<?php

namespace app\models;

use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\helpers\HtmlPurifier;

class RfqQuotation extends ActiveRecord
{
    public const STATUS_CREATED = 'created';
    public const STATUS_ACCEPTED = 'accepted';
    public const STATUS_REJECTED_BY_USER = 'rejected_by_user';
    public const STATUS_CANCELLED_BY_COMPANY = 'cancelled_by_company';

    public static function tableName()
    {
        return '{{%rfq_quotation}}';
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
            [['request_id', 'company_id', 'price_per_unit', 'total_price', 'delivery_time_days', 'payment_terms', 'valid_until'], 'required'],
            [['request_id', 'company_id', 'delivery_time_days'], 'integer'],
            [['price_per_unit', 'total_price', 'delivery_cost'], 'number', 'min' => 0],
            [['notes'], 'string'],
            [['payment_terms'], 'string', 'max' => 255],
            [['valid_until'], 'datetime', 'format' => 'php:Y-m-d H:i:s'],
            [['status'], 'string', 'max' => 32],
            [['status'], 'in', 'range' => [self::STATUS_CREATED, self::STATUS_ACCEPTED, self::STATUS_REJECTED_BY_USER, self::STATUS_CANCELLED_BY_COMPANY]],
            [['request_id'], 'exist', 'targetClass' => RfqRequest::class, 'targetAttribute' => ['request_id' => 'id']],
            [['company_id'], 'exist', 'targetClass' => User::class, 'targetAttribute' => ['company_id' => 'id']],

            // Basic XSS hardening
            [['payment_terms'], 'filter', 'filter' => static fn($v) => trim(strip_tags((string)$v))],
            [['notes'], 'filter', 'filter' => static fn($v) => $v === null ? null : HtmlPurifier::process((string)$v, ['HTML.Allowed' => ''])],
        ];
    }

    /**
     * Ensure JSON responses contain correct scalar types (MySQL DECIMAL may come as string).
     */
    public function fields()
    {
        return [
            'id' => fn() => (int)$this->id,
            'request_id' => fn() => (int)$this->request_id,
            'company_id' => fn() => (int)$this->company_id,
            'price_per_unit' => fn() => (float)$this->price_per_unit,
            'total_price' => fn() => (float)$this->total_price,
            'delivery_time_days' => fn() => (int)$this->delivery_time_days,
            'delivery_cost' => fn() => (float)$this->delivery_cost,
            'payment_terms' => fn() => (string)$this->payment_terms,
            'notes' => fn() => $this->notes === null ? null : (string)$this->notes,
            'valid_until' => fn() => (string)$this->valid_until,
            'status' => fn() => (string)$this->status,
            'created_at' => fn() => (int)$this->created_at,
            'updated_at' => fn() => (int)$this->updated_at,
        ];
    }

    public function getRequest()
    {
        return $this->hasOne(RfqRequest::class, ['id' => 'request_id']);
    }

    public function getCompany()
    {
        return $this->hasOne(User::class, ['id' => 'company_id']);
    }
}


