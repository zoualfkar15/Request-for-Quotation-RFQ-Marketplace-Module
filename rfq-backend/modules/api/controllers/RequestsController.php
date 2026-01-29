<?php

namespace app\modules\api\controllers;

use app\models\CategorySubscription;
use app\models\RfqQuotation;
use app\models\RfqRequest;
use app\models\User;
use Yii;
use yii\db\Expression;
use yii\web\BadRequestHttpException;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;

class RequestsController extends BaseApiController
{
    public function actionIndex()
    {
        /** @var User $actor */
        $actor = Yii::$app->user->identity;
        if ($actor->isCompany()) {
            return $this->actionAvailable();
        }
        return $this->actionMy();
    }

    public function actionMy()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser()) {
            throw new ForbiddenHttpException('Only end-users can view my requests.');
        }

        $q = RfqRequest::find()
            ->where(['user_id' => (int)$user->id])
            ->andWhere(['status' => RfqRequest::STATUS_OPEN])
            ->andWhere(['>', 'expires_at', new Expression('NOW()')])
            ->orderBy(['created_at' => SORT_DESC]);

        return array_map(static fn(RfqRequest $m) => $m->toArray(), $q->all());
    }

    /**
     * GET /api/requests/history
     *
     * - end-user: my closed/awarded/cancelled/expired requests
     * - company: requests where my quotation is accepted/rejected/withdrawn
     */
    public function actionHistory()
    {
        /** @var User $actor */
        $actor = Yii::$app->user->identity;

        if ($actor->isEndUser()) {
            $q = RfqRequest::find()
                ->where(['user_id' => (int)$actor->id])
                ->andWhere([
                    'or',
                    ['<>', 'status', RfqRequest::STATUS_OPEN],
                    ['<=', 'expires_at', new Expression('NOW()')],
                ])
                ->orderBy(['updated_at' => SORT_DESC, 'created_at' => SORT_DESC]);

            return array_map(static fn(RfqRequest $m) => $m->toArray(), $q->all());
        }

        if ($actor->isCompany()) {
            $q = RfqQuotation::find()
                ->alias('q')
                ->joinWith(['request r'])
                ->where(['q.company_id' => (int)$actor->id])
                ->andWhere(['<>', 'q.status', RfqQuotation::STATUS_CREATED])
                ->orderBy(['q.updated_at' => SORT_DESC, 'q.created_at' => SORT_DESC]);

            $rows = [];
            foreach ($q->all() as $quotation) {
                /** @var RfqQuotation $quotation */
                $request = $quotation->request;
                if (!$request) continue;
                $rows[] = [
                    'request' => $request->toArray(),
                    'quotation' => $quotation->toArray(),
                ];
            }
            return $rows;
        }

        throw new ForbiddenHttpException('Forbidden.');
    }

    public function actionAvailable()
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can browse available requests.');
        }

        $q = RfqRequest::find()
            ->where(['status' => RfqRequest::STATUS_OPEN])
            ->andWhere(['>', 'expires_at', new Expression('NOW()')])
            ->orderBy(['created_at' => SORT_DESC]);

        $categoryId = (int)Yii::$app->request->get('category_id', 0);
        if ($categoryId > 0) {
            $q->andWhere(['category_id' => $categoryId]);
        }

        return array_map(static fn(RfqRequest $m) => $m->toArray(), $q->all());
    }

    public function actionView($id)
    {
        $request = RfqRequest::findOne((int)$id);
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }

        /** @var User $actor */
        $actor = Yii::$app->user->identity;
        if ($actor->isEndUser() && (int)$request->user_id !== (int)$actor->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ($actor->isCompany()) {
            // Subscriptions are used for notifications only, not for data visibility.
        }

        return $request->toArray();
    }

    public function actionCreate()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser()) {
            throw new ForbiddenHttpException('Only end-users can create requests.');
        }

        $body = Yii::$app->request->getBodyParams();

        $model = new RfqRequest();
        $model->user_id = (int)$user->id;
        $model->category_id = (int)($body['category_id'] ?? 0);
        $model->title = trim((string)($body['title'] ?? ''));
        $model->description = (string)($body['description'] ?? '');
        $model->quantity = (float)($body['quantity'] ?? 0);
        $model->unit = trim((string)($body['unit'] ?? ''));
        $model->delivery_city = trim((string)($body['delivery_city'] ?? ''));
        $model->delivery_lat = $body['delivery_lat'] ?? null;
        $model->delivery_lng = $body['delivery_lng'] ?? null;
        $model->required_delivery_date = $this->normalizeDate($body['required_delivery_date'] ?? null);
        $model->budget_min = $body['budget_min'] ?? null;
        $model->budget_max = $body['budget_max'] ?? null;
        $model->expires_at = $this->normalizeDateTime($body['expires_at'] ?? null);
        $model->status = RfqRequest::STATUS_OPEN;

        if (!$model->save()) {
            Yii::error($model->errors, __METHOD__);
            Yii::$app->response->statusCode = 422;
            return [
                'message' => 'Validation failed.',
                'errors' => $model->errors,
            ];
        }

        // Real-time: notify companies subscribed to this category
        $qty = (string)$model->quantity;
        $unit = trim((string)$model->unit);
        $city = trim((string)$model->delivery_city);
        $meta = trim(implode(' • ', array_filter([
            trim($qty . ' ' . $unit),
            $city,
        ])));
        Yii::$app->centrifugo->publish('category.' . (int)$model->category_id, [
            'type' => 'request_created',
            'payload' => [
                'title' => 'New Request',
                'message' => trim((string)$model->title) . ($meta !== '' ? ("\n" . $meta) : ''),
            ],
            'request' => $model->toArray(),
        ]);

        return $model->toArray();
    }

    public function actionUpdate($id)
    {
        $request = RfqRequest::findOne((int)$id);
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }

        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser() || (int)$request->user_id !== (int)$user->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ((string)$request->status !== RfqRequest::STATUS_OPEN) {
            throw new BadRequestHttpException('Only open requests can be updated.');
        }

        $body = Yii::$app->request->getBodyParams();
        foreach (['title', 'description', 'unit', 'delivery_city'] as $field) {
            if (array_key_exists($field, $body)) {
                $request->$field = $body[$field];
            }
        }
        if (array_key_exists('category_id', $body)) {
            $request->category_id = (int)$body['category_id'];
        }
        if (array_key_exists('quantity', $body)) {
            $request->quantity = (float)$body['quantity'];
        }
        if (array_key_exists('delivery_lat', $body)) {
            $request->delivery_lat = $body['delivery_lat'];
        }
        if (array_key_exists('delivery_lng', $body)) {
            $request->delivery_lng = $body['delivery_lng'];
        }
        if (array_key_exists('required_delivery_date', $body)) {
            $request->required_delivery_date = $this->normalizeDate($body['required_delivery_date']);
        }
        if (array_key_exists('budget_min', $body)) {
            $request->budget_min = $body['budget_min'];
        }
        if (array_key_exists('budget_max', $body)) {
            $request->budget_max = $body['budget_max'];
        }
        if (array_key_exists('expires_at', $body)) {
            $request->expires_at = $this->normalizeDateTime($body['expires_at']);
        }

        if (!$request->save()) {
            Yii::error($request->errors, __METHOD__);
            Yii::$app->response->statusCode = 422;
            return [
                'message' => 'Validation failed.',
                'errors' => $request->errors,
            ];
        }

        return $request->toArray();
    }

    public function actionCancel($id)
    {
        $request = RfqRequest::findOne((int)$id);
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }

        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser() || (int)$request->user_id !== (int)$user->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ((string)$request->status !== RfqRequest::STATUS_OPEN) {
            throw new BadRequestHttpException('Only open requests can be cancelled.');
        }

        $request->status = RfqRequest::STATUS_CANCELLED;
        if (!$request->save(false, ['status', 'updated_at'])) {
            throw new BadRequestHttpException('Unable to cancel request.');
        }
        return $request->toArray();
    }

    public function actionClose($id)
    {
        $request = RfqRequest::findOne((int)$id);
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }

        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser() || (int)$request->user_id !== (int)$user->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ((string)$request->status !== RfqRequest::STATUS_OPEN) {
            throw new BadRequestHttpException('Only open requests can be closed.');
        }

        $request->status = RfqRequest::STATUS_CLOSED;
        $request->save(false, ['status', 'updated_at']);
        return $request->toArray();
    }

    private function normalizeDate($value): string
    {
        if ($value === null || $value === '') {
            throw new BadRequestHttpException('required_delivery_date is required.');
        }
        $ts = strtotime((string)$value);
        if (!$ts) {
            throw new BadRequestHttpException('Invalid date.');
        }
        return date('Y-m-d', $ts);
    }

    private function normalizeDateTime($value): string
    {
        if ($value === null || $value === '') {
            throw new BadRequestHttpException('expires_at is required.');
        }
        $dt = \DateTime::createFromFormat('Y-m-d H:i:s', (string)$value, new \DateTimeZone('UTC'));
        if (!$dt) {
            throw new BadRequestHttpException('Invalid datetime.');
        }
        $dt->setTimezone(new \DateTimeZone('UTC'));
        return $dt->format('Y-m-d H:i:s');
    }
}


