<?php

namespace app\modules\api\controllers;

use app\models\Notification;
use app\models\User;
use Yii;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;

class NotificationsController extends BaseApiController
{
    public function actionIndex()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        $q = Notification::find()
            ->where(['recipient_user_id' => (int)$user->id])
            ->orderBy(['created_at' => SORT_DESC]);

        return $q->asArray()->all();
    }

    public function actionRead($id)
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        $n = Notification::findOne((int)$id);
        if (!$n) {
            throw new NotFoundHttpException('Notification not found.');
        }
        if ((int)$n->recipient_user_id !== (int)$user->id) {
            throw new ForbiddenHttpException('Forbidden.');
        }

        $n->is_read = 1;
        $n->save(false, ['is_read']);
        return ['ok' => true];
    }
}


