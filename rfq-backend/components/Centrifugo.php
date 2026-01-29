<?php

namespace app\components;

use Yii;
use yii\base\Component;
use yii\base\Exception;

/**
 * Publishes real-time events to Centrifugo via its HTTP API.
 *
 * Config in `params.php`:
 * - centrifugoApiUrl: e.g. http://127.0.0.1:8001/api
 * - centrifugoApiKey: API key configured in centrifugo
 */
class Centrifugo extends Component
{
    /**
     * @throws Exception on hard failure
     */
    public function publish(string $channel, array $data): bool
    {
        $apiUrl = Yii::$app->params['centrifugoApiUrl'] ?? null;
        $apiKey = Yii::$app->params['centrifugoApiKey'] ?? null;
        if (!$apiUrl || !$apiKey) {
            // WS is optional in local setup; don't hard-fail API behavior.
            Yii::warning('Centrifugo not configured; skipping publish to ' . $channel, __METHOD__);
            return false;
        }

        $payload = [
            'method' => 'publish',
            'params' => [
                'channel' => $channel,
                'data' => $data,
            ],
        ];

        $ch = curl_init($apiUrl);
        if ($ch === false) {
            throw new Exception('Failed to init curl');
        }

        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: apikey ' . $apiKey,
            ],
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_SLASHES),
            CURLOPT_TIMEOUT => 3,
        ]);

        $response = curl_exec($ch);
        $err = curl_error($ch);
        $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        // NOTE: `curl_close()` is deprecated as of PHP 8.5 (no-op since PHP 8.0).
        // Yii may convert deprecation warnings to exceptions in dev, causing 500s.
        // We intentionally do not call it here.

        if ($response === false) {
            Yii::warning('Centrifugo publish failed: ' . $err, __METHOD__);
            return false;
        }
        if ($code < 200 || $code >= 300) {
            Yii::warning('Centrifugo publish non-2xx (' . $code . '): ' . $response, __METHOD__);
            return false;
        }

        return true;
    }
}


