<?php

namespace app\components;

use Yii;

/**
 * Minimal JWT HS256 helper (no external deps).
 *
 * NOTE: This is intentionally small for the assessment scope.
 */
final class Jwt
{
    public static function encode(array $payload, ?string $secret = null): string
    {
        $secret = $secret ?? static::secret();
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];

        $segments = [
            static::b64urlEncode(json_encode($header, JSON_UNESCAPED_SLASHES)),
            static::b64urlEncode(json_encode($payload, JSON_UNESCAPED_SLASHES)),
        ];

        $signingInput = implode('.', $segments);
        $signature = hash_hmac('sha256', $signingInput, $secret, true);
        $segments[] = static::b64urlEncode($signature);

        return implode('.', $segments);
    }

    public static function decode(string $jwt, ?string $secret = null): ?array
    {
        $secret = $secret ?? static::secret();
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            return null;
        }

        [$encodedHeader, $encodedPayload, $encodedSig] = $parts;
        $headerJson = static::b64urlDecode($encodedHeader);
        $payloadJson = static::b64urlDecode($encodedPayload);
        $sig = static::b64urlDecode($encodedSig);

        $header = json_decode($headerJson, true);
        $payload = json_decode($payloadJson, true);
        if (!is_array($header) || !is_array($payload)) {
            return null;
        }
        if (($header['alg'] ?? null) !== 'HS256') {
            return null;
        }

        $signingInput = $encodedHeader . '.' . $encodedPayload;
        $expected = hash_hmac('sha256', $signingInput, $secret, true);
        if (!hash_equals($expected, $sig)) {
            return null;
        }

        if (isset($payload['exp']) && is_numeric($payload['exp']) && (int)$payload['exp'] < time()) {
            return null;
        }

        return $payload;
    }

    private static function secret(): string
    {
        return (string)(Yii::$app->params['jwtSecret'] ?? 'change-me');
    }

    private static function b64urlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function b64urlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/')) ?: '';
    }
}


