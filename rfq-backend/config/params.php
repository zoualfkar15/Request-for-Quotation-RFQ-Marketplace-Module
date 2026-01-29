<?php

return [
    'adminEmail' => 'admin@example.com',
    'senderEmail' => 'noreply@example.com',
    'senderName' => 'Example.com mailer',
    // API/JWT
    'jwtSecret' => 'change-me-in-env',
    'jwtTtlSeconds' => 60 * 60 * 24 * 7, // 7 days
    'refreshTokenTtlSeconds' => 60 * 60 * 24 * 30, // 30 days
    // WebSocket event publishing (Centrifugo recommended)
    // - centrifugo API endpoint: e.g. http://127.0.0.1:8001/api
    // - API key: configured in centrifugo
    // Local dev defaults (docker-compose runs Centrifugo on :8001)
    'centrifugoApiUrl' => getenv('CENTRIFUGO_API_URL') ?: 'http://127.0.0.1:8001/api',
    'centrifugoApiKey' => getenv('CENTRIFUGO_API_KEY') ?: 'rfq_centrifugo_api_key_change_me',
    // Centrifugo client JWT (for websocket connections)
    'centrifugoJwtSecret' => getenv('CENTRIFUGO_JWT_SECRET') ?: 'rfq_centrifugo_jwt_secret_change_me',
    'centrifugoJwtTtlSeconds' => 60 * 60 * 24, // 24 hours
];
