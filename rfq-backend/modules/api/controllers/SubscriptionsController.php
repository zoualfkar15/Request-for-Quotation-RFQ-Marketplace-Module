<?php

namespace app\modules\api\controllers;

use app\models\CategorySubscription;
use app\models\User;
use Yii;
use yii\web\BadRequestHttpException;

class SubscriptionsController extends BaseApiController
{
    public function actionIndex()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        $subs = CategorySubscription::find()
            ->where(['user_id' => (int)$user->id])
            ->with('category')
            ->orderBy(['created_at' => SORT_DESC])
            ->all();

        return array_map(static function (CategorySubscription $sub) {
            return [
                'category_id' => (int)$sub->category_id,
                'category' => $sub->category ? $sub->category->toArray() : null,
                'created_at' => (int)$sub->created_at,
            ];
        }, $subs);
    }

    /**
     * Toggle subscribe/unsubscribe for a category.
     * Body: { "category_id": 1 }
     */
    public function actionToggle()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        $body = Yii::$app->request->getBodyParams();
        $categoryId = (int)($body['category_id'] ?? 0);
        if ($categoryId <= 0) {
            throw new BadRequestHttpException('category_id is required.');
        }

        $existing = CategorySubscription::findOne(['user_id' => (int)$user->id, 'category_id' => $categoryId]);
        if ($existing) {
            $existing->delete();
            return ['subscribed' => false];
        }

        $sub = new CategorySubscription([
            'user_id' => (int)$user->id,
            'category_id' => $categoryId,
        ]);
        if (!$sub->save()) {
            throw new BadRequestHttpException('Unable to subscribe.');
        }
        return ['subscribed' => true];
    }
}


