<?php

namespace app\modules\api\controllers;

use app\models\CategorySubscription;
use app\models\Notification;
use app\models\Offer;
use app\models\User;
use Yii;
use yii\db\Expression;
use yii\web\BadRequestHttpException;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;

class OffersController extends BaseApiController
{
    public function actionIndex()
    {
        /** @var User $actor */
        $actor = Yii::$app->user->identity;
        return $actor->isCompany() ? $this->actionMy() : $this->actionAvailable();
    }

    public function actionMy()
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can view my offers.');
        }

        $q = Offer::find()
            ->with(['category'])
            ->where(['company_id' => (int)$company->id])
            ->orderBy(['created_at' => SORT_DESC]);

        return array_map(static fn(Offer $m) => $m->toArray(), $q->all());
    }

    public function actionAvailable()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser()) {
            throw new ForbiddenHttpException('Only end-users can view available offers.');
        }

        $q = Offer::find()
            ->with(['category'])
            ->where(['status' => Offer::STATUS_ACTIVE])
            ->andWhere([
                'or',
                ['available_from' => null],
                ['<=', 'available_from', new Expression('NOW()')],
            ])
            ->andWhere([
                'or',
                ['available_until' => null],
                ['>', 'available_until', new Expression('NOW()')],
            ])
            ->orderBy(['created_at' => SORT_DESC]);

        $categoryId = (int)Yii::$app->request->get('category_id', 0);
        if ($categoryId > 0) {
            $q->andWhere(['category_id' => $categoryId]);
        }

        return array_map(static fn(Offer $m) => $m->toArray(), $q->all());
    }

    public function actionView($id)
    {
        $offer = Offer::findOne((int)$id);
        if (!$offer) {
            throw new NotFoundHttpException('Offer not found.');
        }

        /** @var User $actor */
        $actor = Yii::$app->user->identity;
        if ($actor->isCompany()) {
            if ((int)$offer->company_id !== (int)$actor->id) {
                throw new ForbiddenHttpException('Forbidden.');
            }
            $company = $offer->company;
            $category = $offer->category;
            return [
                'offer' => $offer->toArray(),
                'company' => $company ? [
                    'id' => (int)$company->id,
                    'company_name' => $company->company_name ? (string)$company->company_name : null,
                    'rating' => (float)$company->rating,
                ] : null,
                'category' => $category ? [
                    'id' => (int)$category->id,
                    'name' => (string)$category->name,
                    'slug' => (string)$category->slug,
                ] : null,
            ];
        }

        $company = $offer->company;
        $category = $offer->category;
        return [
            'offer' => $offer->toArray(),
            'company' => $company ? [
                'id' => (int)$company->id,
                'company_name' => $company->company_name ? (string)$company->company_name : null,
                'rating' => (float)$company->rating,
            ] : null,
            'category' => $category ? [
                'id' => (int)$category->id,
                'name' => (string)$category->name,
                'slug' => (string)$category->slug,
            ] : null,
        ];
    }

    public function actionCreate()
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can create offers.');
        }

        $body = Yii::$app->request->getBodyParams();

        $offer = new Offer();
        $offer->company_id = (int)$company->id;
        $offer->category_id = (int)($body['category_id'] ?? 0);
        $offer->title = (string)($body['title'] ?? '');
        $offer->description = (string)($body['description'] ?? '');
        $offer->unit = (string)($body['unit'] ?? '');
        $offer->min_quantity = $body['min_quantity'] ?? null;
        $offer->price_per_unit = (float)($body['price_per_unit'] ?? 0);
        $offer->delivery_city = $body['delivery_city'] ?? null;
        $offer->available_from = $this->normalizeDateTimeNullable($body['available_from'] ?? null);
        $offer->available_until = $this->normalizeDateTimeNullable($body['available_until'] ?? null);
        $offer->status = Offer::STATUS_ACTIVE;

        if (!$offer->save()) {
            Yii::error($offer->errors, __METHOD__);
            throw new BadRequestHttpException('Unable to create offer.');
        }

        $this->notifyOfferCreated($offer);

        return $offer->toArray();
    }

    public function actionUpdate($id)
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can update offers.');
        }

        $offer = Offer::findOne((int)$id);
        if (!$offer) {
            throw new NotFoundHttpException('Offer not found.');
        }
        if ((int)$offer->company_id !== (int)$company->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }

        $body = Yii::$app->request->getBodyParams();
        foreach (['category_id', 'title', 'description', 'unit', 'min_quantity', 'price_per_unit', 'delivery_city', 'status'] as $field) {
            if (array_key_exists($field, $body)) {
                $offer->$field = $body[$field];
            }
        }
        if (array_key_exists('available_from', $body)) {
            $offer->available_from = $this->normalizeDateTimeNullable($body['available_from']);
        }
        if (array_key_exists('available_until', $body)) {
            $offer->available_until = $this->normalizeDateTimeNullable($body['available_until']);
        }

        if (!$offer->save()) {
            throw new BadRequestHttpException('Unable to update offer.');
        }
        return $offer->toArray();
    }

    public function actionDelete($id)
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can delete offers.');
        }

        $offer = Offer::findOne((int)$id);
        if (!$offer) {
            throw new NotFoundHttpException('Offer not found.');
        }
        if ((int)$offer->company_id !== (int)$company->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }

        $offer->delete();
        return ['ok' => true];
    }

    public function actionDeactivate($id)
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can deactivate offers.');
        }

        $offer = Offer::findOne((int)$id);
        if (!$offer) {
            throw new NotFoundHttpException('Offer not found.');
        }
        if ((int)$offer->company_id !== (int)$company->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }

        $offer->status = Offer::STATUS_INACTIVE;
        $offer->save(false, ['status', 'updated_at']);
        return $offer->toArray();
    }

    private function notifyOfferCreated(Offer $offer): void
    {
        // Persist notifications for subscribed end-users (useful for "notifications list")
        $userIds = CategorySubscription::find()
            ->alias('s')
            ->select(['s.user_id'])
            ->joinWith([
                'user u' => static function ($q) {
                    /** @var \yii\db\ActiveQuery $q */
                    $q->alias('u');
                },
            ])
            ->where([
                's.category_id' => (int)$offer->category_id,
                'u.role' => User::ROLE_USER,
                'u.status' => 10,
            ])
            ->column();

        if (!$userIds) {
            return;
        }

        // Real-time banner: publish ONLY to subscribed end-users (user.{id}) so:
        // - companies never receive it
        // - users only receive it if they subscribed to this category
        $title = trim((string)$offer->title);
        $ppu = (string)$offer->price_per_unit;
        $unit = trim((string)$offer->unit);
        $line = trim($ppu . ' / ' . $unit);
        $event = [
            'type' => 'offer_created',
            'payload' => [
                'title' => 'New Offer',
                'message' => ($title !== '' ? $title : 'A company posted a new offer.') . ($line !== '' ? ("\n" . $line) : ''),
            ],
            'offer' => $offer->toArray(),
        ];

        $now = time();
        $rows = [];
        $payload = json_encode([
            'offer_id' => (int)$offer->id,
            'category_id' => (int)$offer->category_id,
            'company_id' => (int)$offer->company_id,
        ], JSON_UNESCAPED_SLASHES);

        foreach ($userIds as $userId) {
            $rows[] = [
                (int)$userId,
                'offer_created',
                $payload,
                0,
                $now,
            ];
        }

        Yii::$app->db->createCommand()->batchInsert(
            Notification::tableName(),
            ['recipient_user_id', 'type', 'payload_json', 'is_read', 'created_at'],
            $rows
        )->execute();

        foreach ($userIds as $userId) {
            Yii::$app->centrifugo->publish('user.' . (int)$userId, $event);
        }
    }

    private function normalizeDateTimeNullable($value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }
        $ts = strtotime((string)$value);
        if (!$ts) {
            throw new BadRequestHttpException('Invalid datetime.');
        }
        return date('Y-m-d H:i:s', $ts);
    }
}


