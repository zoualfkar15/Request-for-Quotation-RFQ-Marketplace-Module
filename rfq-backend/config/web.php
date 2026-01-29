<?php

$params = require __DIR__ . '/params.php';
$db = require __DIR__ . '/db.php';

$config = [
    'id' => 'basic',
    'basePath' => dirname(__DIR__),
    'bootstrap' => ['log'],
    'aliases' => [
        '@bower' => '@vendor/bower-asset',
        '@npm'   => '@vendor/npm-asset',
    ],
    'modules' => [
        'api' => [
            'class' => \app\modules\api\Module::class,
        ],
    ],
    'components' => [
        'request' => [
            // !!! insert a secret key in the following (if it is empty) - this is required by cookie validation
            'cookieValidationKey' => 'PvZLGGVopnP_VsaarB_IEVa1t1dr6sSB',
            'parsers' => [
                'application/json' => 'yii\web\JsonParser',
            ],
        ],
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        'user' => [
            'identityClass' => 'app\models\User',
            'enableAutoLogin' => true,
        ],
        'errorHandler' => [
            'errorAction' => 'site/error',
        ],
        'mailer' => [
            'class' => \yii\symfonymailer\Mailer::class,
            'viewPath' => '@app/mail',
            // send all mails to a file by default.
            'useFileTransport' => true,
        ],
        'log' => [
            'traceLevel' => YII_DEBUG ? 3 : 0,
            'targets' => [
                [
                    'class' => 'yii\log\FileTarget',
                    'levels' => ['error', 'warning'],
                ],
            ],
        ],
        'db' => $db,
        'urlManager' => [
            'enablePrettyUrl' => true,
            'showScriptName' => false,
            'rules' => [
                // Swagger / OpenAPI docs
                'GET docs' => 'docs/index',
                'GET docs/openapi.yaml' => 'docs/openapi',
                'OPTIONS docs' => 'docs/options',
                'OPTIONS docs/openapi.yaml' => 'docs/options',

                // API routes (split per controller so extraPatterns don't leak across controllers)
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/auth'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'POST login' => 'login',
                        'POST register' => 'register',
                        'POST otp/send' => 'otp-send',
                        'POST otp/verify' => 'otp-verify',
                        'POST password/reset' => 'password-reset',
                        'POST refresh' => 'refresh',
                        'POST logout' => 'logout',
                        'GET me' => 'me',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/ws'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'GET token' => 'token',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/categories'],
                    'pluralize' => false,
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/requests'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'GET my' => 'my',
                        'GET available' => 'available',
                        'GET history' => 'history',
                        'POST <id:\\d+>/cancel' => 'cancel',
                        'POST <id:\\d+>/close' => 'close',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/quotations'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'GET by-request/<requestId:\\d+>' => 'by-request',
                        'POST <id:\\d+>/withdraw' => 'withdraw',
                        'POST <id:\\d+>/accept' => 'accept',
                        'POST <id:\\d+>/reject' => 'reject',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/subscriptions'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'POST toggle' => 'toggle',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/notifications'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'POST <id:\\d+>/read' => 'read',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/offers'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'GET my' => 'my',
                        'GET available' => 'available',
                        'POST <id:\\d+>/deactivate' => 'deactivate',
                    ],
                ],
                [
                    'class' => 'yii\rest\UrlRule',
                    'controller' => ['api/dev-notifications'],
                    'pluralize' => false,
                    'extraPatterns' => [
                        'POST broadcast-all' => 'broadcast-all',
                    ],
                ],
            ],
        ],
        'centrifugo' => [
            'class' => \app\components\Centrifugo::class,
        ],
    ],
    'params' => $params,
];

if (YII_ENV_DEV) {
    // configuration adjustments for 'dev' environment
    $config['bootstrap'][] = 'debug';
    $config['modules']['debug'] = [
        'class' => 'yii\debug\Module',
        // uncomment the following to add your IP if you are not connecting from localhost.
        //'allowedIPs' => ['127.0.0.1', '::1'],
    ];

    $config['bootstrap'][] = 'gii';
    $config['modules']['gii'] = [
        'class' => 'yii\gii\Module',
        // uncomment the following to add your IP if you are not connecting from localhost.
        //'allowedIPs' => ['127.0.0.1', '::1'],
    ];
}

return $config;
