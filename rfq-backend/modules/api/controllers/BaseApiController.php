<?php

namespace app\modules\api\controllers;

use Yii;
use yii\filters\Cors;
use yii\filters\auth\HttpBearerAuth;
use yii\web\Response;

class BaseApiController extends \yii\rest\Controller
{
    public $enableCsrfValidation = false;

    public function actions()
    {
        return [
            'options' => [
                'class' => \yii\rest\OptionsAction::class,
            ],
        ];
    }

    public function behaviors()
    {
        $behaviors = parent::behaviors();

        // Always JSON
        $behaviors['contentNegotiator']['formats']['application/json'] = Response::FORMAT_JSON;

        // CORS for web + mobile clients
        $behaviors['corsFilter'] = [
            'class' => Cors::class,
            'cors' => [
                'Origin' => ['*'],
                'Access-Control-Request-Method' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
                // Explicit headers are more compatible than "*" in some browsers/tools.
                'Access-Control-Request-Headers' => ['Authorization', 'Content-Type', 'Accept', 'Origin', 'X-Requested-With'],
                'Access-Control-Allow-Credentials' => false,
                'Access-Control-Max-Age' => 3600,
                'Access-Control-Expose-Headers' => ['*'],
            ],
        ];

        // JWT bearer auth
        $behaviors['authenticator'] = [
            'class' => HttpBearerAuth::class,
            'except' => ['options'],
        ];

        return $behaviors;
    }

    public function beforeAction($action)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        return parent::beforeAction($action);
    }
}


