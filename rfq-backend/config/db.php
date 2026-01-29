<?php

return [
    'class' => 'yii\db\Connection',
    // Use 127.0.0.1 to force TCP (avoid macOS "localhost" unix-socket issues).
    'dsn' => 'mysql:host=127.0.0.1;dbname=yii2basic',
    'username' => 'root',
    'password' => 'root_password',
    'charset' => 'utf8mb4',

    // Schema cache options (for production environment)
    //'enableSchemaCache' => true,
    //'schemaCacheDuration' => 60,
    //'schemaCache' => 'cache',
];
