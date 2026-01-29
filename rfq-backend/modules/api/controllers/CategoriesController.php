<?php

namespace app\modules\api\controllers;

use app\models\Category;
use Yii;
use yii\web\BadRequestHttpException;
use yii\web\NotFoundHttpException;

class CategoriesController extends BaseApiController
{
    public function behaviors()
    {
        $behaviors = parent::behaviors();
        // Allow category browsing without auth (useful for registration flows)
        $behaviors['authenticator']['except'] = ['options', 'index', 'view'];
        return $behaviors;
    }

    public function beforeAction($action)
    {
        $res = parent::beforeAction($action);
        if (!$res) {
            return false;
        }

        // Only admin can manage categories (create/update/delete)
        if (in_array($action->id, ['create', 'update', 'delete'], true)) {
            /** @var \app\models\User|null $user */
            $user = Yii::$app->user->identity;
            if (!$user || !$user->isAdmin()) {
                throw new \yii\web\ForbiddenHttpException('Admin only.');
            }
        }
        return true;
    }

    public function actionIndex()
    {
        return Category::find()
            ->orderBy(['name' => SORT_ASC])
            ->asArray()
            ->all();
    }

    public function actionView($id)
    {
        $category = Category::findOne((int)$id);
        if (!$category) {
            throw new NotFoundHttpException('Category not found.');
        }
        return $category->toArray();
    }

    public function actionCreate()
    {
        $body = Yii::$app->request->getBodyParams();
        $name = trim((string)($body['name'] ?? ''));
        $slug = trim((string)($body['slug'] ?? ''));

        if ($name === '') {
            throw new BadRequestHttpException('name is required.');
        }
        if ($slug === '') {
            $slug = $this->slugify($name);
        }

        $category = new Category([
            'name' => $name,
            'slug' => $slug,
        ]);
        if (!$category->save()) {
            throw new BadRequestHttpException('Unable to create category.');
        }
        return $category->toArray();
    }

    public function actionUpdate($id)
    {
        $category = Category::findOne((int)$id);
        if (!$category) {
            throw new NotFoundHttpException('Category not found.');
        }

        $body = Yii::$app->request->getBodyParams();
        if (array_key_exists('name', $body)) {
            $category->name = trim((string)$body['name']);
        }
        if (array_key_exists('slug', $body)) {
            $category->slug = trim((string)$body['slug']);
        }
        if (!$category->save()) {
            throw new BadRequestHttpException('Unable to update category.');
        }
        return $category->toArray();
    }

    public function actionDelete($id)
    {
        $category = Category::findOne((int)$id);
        if (!$category) {
            throw new NotFoundHttpException('Category not found.');
        }
        $category->delete();
        return ['ok' => true];
    }

    private function slugify(string $name): string
    {
        $slug = strtolower($name);
        $slug = preg_replace('/[^a-z0-9]+/i', '-', $slug) ?? $slug;
        $slug = trim($slug, '-');
        return $slug !== '' ? $slug : 'category';
    }
}


