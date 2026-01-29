# RFQ Marketplace (Yii2 + Flutter + WebSocket)

This repository contains an RFQ (Request For Quotation) marketplace:

- **Backend**: PHP **Yii2** REST API (`rfq-backend/`)
- **Mobile app**: **Flutter** (`flutter_assessment/`)
- **Realtime notifications**: **Centrifugo** WebSocket server (runs separately)

Core features implemented:

- JWT authentication (user/company roles)
- OTP verification + password reset (**OTP fixed to `123456`**, resend throttled to **60 seconds**)
- RFQ Requests, Quotations, Offers CRUD + status management
- Category subscriptions (used for **notifications** targeting)
- WebSocket banner notifications (Centrifugo) + persistent notifications list
- Swagger UI + OpenAPI spec

---

## Backend (Yii2) Setup

### Requirements

- PHP **8+** (project is known to run on PHP **8.5.x**)
- Composer
- MySQL (or MariaDB)

### 1) Install dependencies

```bash
cd rfq-backend
composer install
```

### 2) Database setup

1. Create a database (example: `yii2basic`)
2. Update DB credentials:
   - `rfq-backend/config/db.php`

Example `db.php`:

```php
<?php
return [
  'class' => 'yii\db\Connection',
  'dsn' => 'mysql:host=127.0.0.1;dbname=yii2basic',
  'username' => 'root',
  'password' => 'root_password',
  'charset' => 'utf8mb4',
];
```

### 3) Quick run (import provided DB dump)

If you want to run the project quickly, a MySQL dump is included at the repository root:

- `yii2basic.sql`

Steps:

```bash
# from the repository root
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS yii2basic CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -u root -p yii2basic < yii2basic.sql
```

Then apply any newer migrations (safe if the dump is up-to-date):

```bash
cd rfq-backend
php yii migrate
```

### 4) Run migrations (normal setup)

```bash
cd rfq-backend
php yii migrate
```

### 5) Run the backend locally

```bash
cd rfq-backend
php -S 0.0.0.0:8000 -t web web/index.php
```

Backend base URL:

- `http://127.0.0.1:8000/`
- Android emulator uses `http://10.0.2.2:8000/`

---

## WebSocket / Realtime (Centrifugo) Setup

### What it does

- Mobile app connects to Centrifugo over WebSocket.
- Backend publishes events to Centrifugo over HTTP API.
- Events show as in-app banners and also refresh the related lists automatically.

### Requirements

- Centrifugo **v6.6.0** (or compatible v6)

### 1) Centrifugo config

Config file is included here:

- `rfq-backend/centrifugo/config.json`

Important fields in the config:

- `http_server.port = 8001`
- `http_api.key` must match the backend param `centrifugoApiKey`
- `client.token.hmac_secret_key` must match the backend param `centrifugoJwtSecret`
- `allow_subscribe_for_client` enabled with a safe `channel_regex` for:
  - `user.{id}`
  - `category.{id}`

### 2) Start Centrifugo (non-Docker)

```bash
cd rfq-backend
centrifugo -c centrifugo/config.json
```

Admin UI:

- `http://127.0.0.1:8001/`

WebSocket endpoint:

- `ws://127.0.0.1:8001/connection/websocket`

### 3) Backend environment variables (optional)

Backend defaults are already set in `rfq-backend/config/params.php`, but you can override via env vars:

- `CENTRIFUGO_API_URL` (default `http://127.0.0.1:8001/api`)
- `CENTRIFUGO_API_KEY` (default `rfq_centrifugo_api_key_change_me`)
- `CENTRIFUGO_JWT_SECRET` (default `rfq_centrifugo_jwt_secret_change_me`)

---

## Mobile (Flutter) Setup

### Requirements

- Flutter SDK (Dart SDK compatible with `sdk: ^3.5.3`)

### 1) Install dependencies

```bash
cd flutter_assessment
flutter pub get
```

### 2) Configure endpoints (Android emulator)

`flutter_assessment/lib/core/constant/end_points.dart`:

- Backend: `http://10.0.2.2:8000/`
- WebSocket: `ws://10.0.2.2:8001/connection/websocket`

> Important: use **`ws://`** for local development (no TLS). `wss://` requires TLS config in Centrifugo.

### 3) Run the app

```bash
cd flutter_assessment
flutter run
```

---

## API Documentation

- Swagger UI: `http://127.0.0.1:8000/docs`
- OpenAPI spec: `http://127.0.0.1:8000/docs/openapi.yaml`

Postman:

- Import `rfq-backend/docs/openapi.yaml` into Postman (OpenAPI import).

---

## Demo Credentials (create these via Register)

> If you imported `yii2basic.sql`, you already have sample users/companies in the DB.

Use the mobile app register screen or call:

- `POST /api/auth/register`

Then verify using OTP **`123456`**.

### End-users

- **user1**: `user@gmail.com` / `Pass@2022`

### Companies

- **company1**: `company@gmail.com` / `Pass@2022`

---

## WebSocket Testing (quick)

### 1) Dev-only broadcast endpoint (no auth)

If backend is running in `dev` mode (default in `rfq-backend/web/index.php`), you can broadcast to all active users:

```bash
curl -i -X POST 'http://127.0.0.1:8000/api/dev-notifications/broadcast-all' \
  -H 'Content-Type: application/json' \
  --data-raw '{"title":"Test","message":"Hello from websocket"}'
```

### 2) Events that trigger realtime

- **Create request** (`POST /api/requests`) → publishes `request_created`
- **Submit quotation** (`POST /api/quotations`) → publishes `quotation_created` to the request owner
- **Create offer** (`POST /api/offers`) → publishes `offer_created` **only to subscribed end-users**

---

## Assumptions / Notes

- **OTP is fixed to `123456`** for assessment/testing and is throttled to **1 minute** per send.
- Centrifugo is configured to allow client-side subscriptions only for channels matching:
  - `user.{id}`
  - `category.{id}`
- A dev-only endpoint exists for testing websocket broadcast:
  - `POST /api/dev-notifications/broadcast-all` (only works when `YII_ENV_DEV`)
- Flutter WebSocket handler includes **auto-reconnect** + **re-subscribe** on resume/disconnect.

---

## Technologies / Packages Used

### Backend

- PHP + Yii2 (REST controllers)
- MySQL (migrations)
- JWT auth (Bearer tokens)
- Swagger/OpenAPI (`/docs`, `docs/openapi.yaml`)
- Centrifugo HTTP API publish + WebSocket client tokens

### Mobile (Flutter)

- `get` (GetX)
- `dio` (HTTP) + custom cURL logger interceptor
- `get_storage` (local storage)
- `web_socket_channel` (WebSocket client)
- `fluttertoast`
- `intl`
- `flutter_svg`
- `flutter_screenutil`
