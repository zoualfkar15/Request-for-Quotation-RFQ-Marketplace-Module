<?php

namespace app\modules\api\controllers;

use app\models\Notification;
use app\models\User;
use Yii;
use yii\web\BadRequestHttpException;
use yii\web\NotFoundHttpException;

/**
 * Dev-only helper endpoints (NO AUTH) for testing websocket broadcasts.
 *
 * IMPORTANT: This controller is intentionally open but is guarded by YII_ENV_DEV.
 * Do not use in production.
 */
class DevNotificationsController extends BaseApiController
{
    public function behaviors()
    {
        $behaviors = parent::behaviors();
        // No auth for dev test endpoints
        $behaviors['authenticator']['except'] = ['options', 'broadcast-all'];
        return $behaviors;
    }

    /**
     * POST /api/dev-notifications/broadcast-all
     *
     * Body:
     * - type: string (optional, default "test_broadcast")
     * - payload: object (optional, default {title, message})
     * - title: string (optional, used when payload not provided)
     * - message: string (optional, used when payload not provided)
     */
    public function actionBroadcastAll()
    {
        if (!YII_ENV_DEV) {
            throw new NotFoundHttpException('Not found.');
        }

        $body = Yii::$app->request->getBodyParams();
        $type = trim((string)($body['type'] ?? 'test_broadcast'));
        $payload = $body['payload'] ?? null;

        if ($payload === null) {
            $payload = [
                'title' => (string)($body['title'] ?? 'Test notification'),
                'message' => (string)($body['message'] ?? 'Hello from websocket'),
            ];
        }

        if ($type === '' || !is_array($payload)) {
            throw new BadRequestHttpException('Invalid payload.');
        }

        $userIds = User::find()
            ->select(['id'])
            ->where(['status' => 10])
            ->column();

        if (!$userIds) {
            return ['ok' => true, 'sent' => 0];
        }

        $now = time();
        $payloadJson = json_encode($payload, JSON_UNESCAPED_SLASHES);
        $rows = [];

        foreach ($userIds as $uid) {
            $rows[] = [(int)$uid, $type, $payloadJson, 0, $now];
        }

        Yii::$app->db->createCommand()->batchInsert(
            Notification::tableName(),
            ['recipient_user_id', 'type', 'payload_json', 'is_read', 'created_at'],
            $rows
        )->execute();

        foreach ($userIds as $uid) {
            Yii::$app->centrifugo->publish('user.' . (int)$uid, [
                'type' => $type,
                'payload' => $payload,
            ]);
        }

        return ['ok' => true, 'sent' => count($userIds)];
    }
}


