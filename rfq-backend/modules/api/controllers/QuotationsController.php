<?php

namespace app\modules\api\controllers;

use app\models\Notification;
use app\models\RfqQuotation;
use app\models\RfqRequest;
use app\models\User;
use Yii;
use yii\db\Expression;
use yii\db\Transaction;
use yii\web\BadRequestHttpException;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;

class QuotationsController extends BaseApiController
{
    /**
     * GET /api/quotations/{id}
     *
     * End-user: can view company contact only when quotation is ACCEPTED for their request.
     * Company: can view their own quotation details.
     */
    public function actionView($id)
    {
        $quotation = RfqQuotation::find()
            ->alias('q')
            ->joinWith(['request r', 'company c'])
            ->where(['q.id' => (int)$id])
            ->one();

        if (!$quotation) {
            throw new NotFoundHttpException('Quotation not found.');
        }

        /** @var User $actor */
        $actor = Yii::$app->user->identity;

        $request = $quotation->request;
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }

        if ($actor->isCompany()) {
            if ((int)$quotation->company_id !== (int)$actor->id) {
                throw new ForbiddenHttpException('Forbidden.');
            }
            return [
                'quotation' => $quotation->toArray(),
                'request' => $request->toArray(),
            ];
        }

        if (!$actor->isEndUser() || (int)$request->user_id !== (int)$actor->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }

        // Only expose contact details once accepted (awarded) so we don't leak company data early.
        if ((string)$quotation->status !== RfqQuotation::STATUS_ACCEPTED &&
            (int)$request->awarded_quotation_id !== (int)$quotation->id) {
            throw new ForbiddenHttpException('Company contact is available only after acceptance.');
        }

        $company = $quotation->company;
        $phone = $company ? $company->getAttribute('phone') : null;
        return [
            'quotation' => $quotation->toArray(),
            'request' => $request->toArray(),
            'company' => $company ? [
                'id' => (int)$company->id,
                'company_name' => $company->company_name ? (string)$company->company_name : null,
                'email' => (string)$company->email,
                // Use getAttribute() so API won't 500 if migration wasn't applied yet.
                'phone' => $phone ? (string)$phone : null,
                'rating' => (float)$company->rating,
            ] : null,
        ];
    }

    public function actionIndex()
    {
        /** @var User $actor */
        $actor = Yii::$app->user->identity;
        if ($actor->isCompany()) {
            $q = RfqQuotation::find()
                ->where(['company_id' => (int)$actor->id])
                ->orderBy(['created_at' => SORT_DESC]);

            return array_map(static fn(RfqQuotation $m) => $m->toArray(), $q->all());
        }

        // end-user: list quotations for their requests
        $requestIds = RfqRequest::find()
            ->select('id')
            ->where(['user_id' => (int)$actor->id]);

        $q = RfqQuotation::find()
            ->where(['request_id' => $requestIds])
            ->orderBy(['created_at' => SORT_DESC]);

        return array_map(static fn(RfqQuotation $m) => $m->toArray(), $q->all());
    }

    /**
     * GET /api/quotations/by-request/{requestId}
     */
    public function actionByRequest($requestId)
    {
        $request = RfqRequest::findOne((int)$requestId);
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }
        /** @var User $actor */
        $actor = Yii::$app->user->identity;
        if (!$actor->isEndUser() || (int)$request->user_id !== (int)$actor->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }

        $q = RfqQuotation::find()
            ->alias('q')
            ->joinWith([
                'company' => static function ($q) {
                    /** @var \yii\db\ActiveQuery $q */
                    $q->alias('c');
                },
            ])
            ->where(['q.request_id' => (int)$request->id])
            ->andWhere(['q.status' => RfqQuotation::STATUS_CREATED])
            ->orderBy(new Expression(
                '(q.total_price + q.delivery_cost) ASC, q.delivery_time_days ASC, c.rating DESC, q.created_at ASC'
            ));

        $rows = [];
        $rank = 1;
        foreach ($q->all() as $quotation) {
            /** @var RfqQuotation $quotation */
            $company = $quotation->company;
            $rows[] = [
                'rank' => $rank++,
                'quotation' => $quotation->toArray(),
                'company' => $company ? [
                    'id' => (int)$company->id,
                    'company_name' => $company->company_name ? (string)$company->company_name : null,
                    'rating' => (float)$company->rating,
                ] : null,
            ];
        }

        return [
            'request' => $request->toArray(),
            'quotations' => $rows,
        ];
    }

    public function actionCreate()
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can submit quotations.');
        }

        $body = Yii::$app->request->getBodyParams();
        $requestId = (int)($body['request_id'] ?? 0);
        if ($requestId <= 0) {
            throw new BadRequestHttpException('request_id is required.');
        }

        $request = RfqRequest::findOne($requestId);
        if (!$request) {
            throw new NotFoundHttpException('Request not found.');
        }
        if ((string)$request->status !== RfqRequest::STATUS_OPEN) {
            throw new BadRequestHttpException('Request is not open.');
        }

        $quotation = new RfqQuotation();
        $quotation->request_id = (int)$request->id;
        $quotation->company_id = (int)$company->id;
        $quotation->price_per_unit = (float)($body['price_per_unit'] ?? 0);
        $quotation->delivery_time_days = (int)($body['delivery_time_days'] ?? 0);
        $quotation->delivery_cost = (float)($body['delivery_cost'] ?? 0);
        $quotation->payment_terms = trim((string)($body['payment_terms'] ?? ''));
        $quotation->notes = $body['notes'] ?? null;
        $quotation->valid_until = $this->normalizeDateTime($body['valid_until'] ?? null);
        $quotation->status = RfqQuotation::STATUS_CREATED;

        $total = $body['total_price'] ?? null;
        $quotation->total_price = $total !== null ? (float)$total : (float)($quotation->price_per_unit * (float)$request->quantity);

        if (!$quotation->save()) {
            Yii::error($quotation->errors, __METHOD__);
            throw new BadRequestHttpException('Unable to create quotation.');
        }

        // Notification log + real-time to request owner
        $notification = new Notification([
            'recipient_user_id' => (int)$request->user_id,
            'type' => 'quotation_created',
            'payload_json' => json_encode([
                'request_id' => (int)$request->id,
                'quotation_id' => (int)$quotation->id,
                'company_id' => (int)$company->id,
            ], JSON_UNESCAPED_SLASHES),
            'created_at' => time(),
        ]);
        $notification->save(false);

        $lines = [];
        $lines[] = 'Request #' . (int)$request->id;
        $total = $quotation->total_price !== null ? (string)$quotation->total_price : '';
        if ($total !== '') {
            $lines[] = 'Total: ' . $total;
        }
        $days = (int)$quotation->delivery_time_days;
        if ($days > 0) {
            $lines[] = 'Delivery: ' . $days . ' days';
        }

        Yii::$app->centrifugo->publish('user.' . (int)$request->user_id, [
            'type' => 'quotation_created',
            'payload' => [
                'title' => 'New Quotation',
                'message' => implode(' • ', $lines),
            ],
            'request_id' => (int)$request->id,
            'quotation' => $quotation->toArray(),
        ]);

        return $quotation->toArray();
    }

    public function actionUpdate($id)
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can update quotations.');
        }

        $quotation = RfqQuotation::findOne((int)$id);
        if (!$quotation) {
            throw new NotFoundHttpException('Quotation not found.');
        }
        if ((int)$quotation->company_id !== (int)$company->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ((string)$quotation->status !== RfqQuotation::STATUS_CREATED) {
            throw new BadRequestHttpException('Only created quotations can be updated.');
        }

        $body = Yii::$app->request->getBodyParams();
        foreach (['price_per_unit', 'total_price', 'delivery_time_days', 'delivery_cost', 'payment_terms', 'notes'] as $field) {
            if (array_key_exists($field, $body)) {
                $quotation->$field = $body[$field];
            }
        }
        if (array_key_exists('valid_until', $body)) {
            $quotation->valid_until = $this->normalizeDateTime($body['valid_until']);
        }

        if (!$quotation->save()) {
            throw new BadRequestHttpException('Unable to update quotation.');
        }
        return $quotation->toArray();
    }

    public function actionWithdraw($id)
    {
        /** @var User $company */
        $company = Yii::$app->user->identity;
        if (!$company->isCompany()) {
            throw new ForbiddenHttpException('Only companies can withdraw quotations.');
        }

        $quotation = RfqQuotation::findOne((int)$id);
        if (!$quotation) {
            throw new NotFoundHttpException('Quotation not found.');
        }
        if ((int)$quotation->company_id !== (int)$company->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ((string)$quotation->status !== RfqQuotation::STATUS_CREATED) {
            throw new BadRequestHttpException('Only created quotations can be cancelled.');
        }

        $quotation->status = RfqQuotation::STATUS_CANCELLED_BY_COMPANY;
        $quotation->save(false, ['status', 'updated_at']);
        return $quotation->toArray();
    }

    public function actionAccept($id)
    {
        return $this->decide($id, true);
    }

    public function actionReject($id)
    {
        return $this->decide($id, false);
    }

    private function decide($id, bool $accept)
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (!$user->isEndUser()) {
            throw new ForbiddenHttpException('Only end-users can decide on quotations.');
        }

        $quotation = RfqQuotation::findOne((int)$id);
        if (!$quotation) {
            throw new NotFoundHttpException('Quotation not found.');
        }
        $request = RfqRequest::findOne((int)$quotation->request_id);
        if (!$request || (int)$request->user_id !== (int)$user->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }
        if ((string)$quotation->status !== RfqQuotation::STATUS_CREATED) {
            throw new BadRequestHttpException('Only created quotations can be accepted/rejected.');
        }

        $db = Yii::$app->db;
        $tx = $db->beginTransaction(Transaction::SERIALIZABLE);
        try {
            if ($accept) {
                $quotation->status = RfqQuotation::STATUS_ACCEPTED;
                $quotation->save(false, ['status', 'updated_at']);

                $request->status = RfqRequest::STATUS_AWARDED;
                $request->awarded_quotation_id = (int)$quotation->id;
                $request->save(false, ['status', 'awarded_quotation_id', 'updated_at']);

                // Reject all other pending quotations for the request
                RfqQuotation::updateAll(
                    ['status' => RfqQuotation::STATUS_REJECTED_BY_USER, 'updated_at' => time()],
                    [
                        'and',
                        ['request_id' => (int)$request->id],
                        ['status' => RfqQuotation::STATUS_CREATED],
                        ['<>', 'id', (int)$quotation->id],
                    ]
                );
            } else {
                $quotation->status = RfqQuotation::STATUS_REJECTED_BY_USER;
                $quotation->save(false, ['status', 'updated_at']);

                // "Hide together": when a quotation is rejected, close the request,
                // and mark all remaining pending quotations as rejected too.
                $request->status = RfqRequest::STATUS_CLOSED;
                $request->save(false, ['status', 'updated_at']);

                RfqQuotation::updateAll(
                    ['status' => RfqQuotation::STATUS_REJECTED_BY_USER, 'updated_at' => time()],
                    [
                        'and',
                        ['request_id' => (int)$request->id],
                        ['status' => RfqQuotation::STATUS_CREATED],
                    ]
                );
            }

            $tx->commit();
        } catch (\Throwable $e) {
            $tx->rollBack();
            throw $e;
        }

        return [
            'request' => $request->toArray(),
            'quotation' => $quotation->toArray(),
        ];
    }

    private function normalizeDateTime($value): string
    {
        if ($value === null || $value === '') {
            throw new BadRequestHttpException('valid_until is required.');
        }
        $dt = \DateTime::createFromFormat('Y-m-d H:i:s', (string)$value, new \DateTimeZone('UTC'));
        if (!$dt) {
            throw new BadRequestHttpException('Invalid datetime.');
        }
        $dt->setTimezone(new \DateTimeZone('UTC'));
        return $dt->format('Y-m-d H:i:s');
    }
}


