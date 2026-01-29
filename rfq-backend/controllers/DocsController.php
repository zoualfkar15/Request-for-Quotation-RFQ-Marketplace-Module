<?php

namespace app\controllers;

use Yii;
use yii\filters\Cors;
use yii\web\Controller;
use yii\web\Response;

class DocsController extends Controller
{
    public $enableCsrfValidation = false;

    public function behaviors()
    {
        $behaviors = parent::behaviors();
        $behaviors['corsFilter'] = [
            'class' => Cors::class,
            'cors' => [
                'Origin' => ['*'],
                'Access-Control-Request-Method' => ['GET', 'OPTIONS'],
                'Access-Control-Request-Headers' => ['*'],
                'Access-Control-Allow-Credentials' => false,
                'Access-Control-Max-Age' => 3600,
            ],
        ];
        return $behaviors;
    }

    public function actionIndex()
    {
        Yii::$app->response->format = Response::FORMAT_HTML;

        // Using CDN for Swagger UI to keep the backend lightweight.
        $specUrl = Yii::$app->urlManager->createAbsoluteUrl(['/docs/openapi.yaml']);

        return $this->renderContent(<<<HTML
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>RFQ Backend API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
    <style>
      body { margin: 0; background: #0b1020; }
      .topbar { display: none; }
      #swagger-ui { background: #fff; }
    </style>
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
      window.onload = () => {
        SwaggerUIBundle({
          url: "{$specUrl}",
          dom_id: "#swagger-ui",
          persistAuthorization: true,
        });
      };
    </script>
  </body>
</html>
HTML);
    }

    public function actionOpenapi()
    {
        $path = Yii::getAlias('@app/docs/openapi.yaml');
        Yii::$app->response->format = Response::FORMAT_RAW;
        Yii::$app->response->headers->set('Content-Type', 'application/yaml; charset=utf-8');
        return file_get_contents($path) ?: '';
    }

    public function actionOptions()
    {
        Yii::$app->response->statusCode = 204;
        return '';
    }
}


