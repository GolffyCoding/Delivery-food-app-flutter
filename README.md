# 🛵 OpenDelivery

A full-stack, three-sided food delivery platform — **Customer**, **Driver**, and **Merchant** apps built with Flutter, backed by a real Go API. Built as a from-scratch clone of the Coupang Eats experience: order placement, live tracking, coupons, reviews, and a kitchen-display dashboard for restaurants, all wired to a real backend rather than mocked screens.

> Order food → restaurant accepts → driver picks up → live ETA on a map → rate your order. All four roles talk to the same backend, in real time, over WebSockets.

---

## ✨ Highlights

- **Not a UI mockup.** Every screen you can tap is backed by a real HTTP call to the Go API in [`Delivery-go`](../Delivery-go) — restaurants, orders, coupons, reviews, notifications, and driver GPS all come from Postgres, not hardcoded lists.
- **One-tap demo login.** No account? Hit *"Try Demo Account"* on the login screen — it registers a demo user on first run and logs straight in. Zero setup to start clicking around.
- **Real-time everywhere.** Order status, driver location, and live ETA push over a single WebSocket connection (`order:<id>` / `driver:<id>` rooms) — no polling.
- **Three apps, one design system.** A shared `packages/` layer (design tokens, reusable widgets, networking, auth, state machine) keeps Customer/Driver/Merchant visually and behaviorally consistent instead of three divergent codebases.
- **A state machine, not a status string.** Order lifecycle transitions (`pending → accepted → preparing → ready → picked_up → delivering → delivered/cancelled`) are enforced by a typed state machine, so the UI can never render an impossible order state.

---

## 📱 The three apps

| App | Who it's for | What it does |
|---|---|---|
| **Customer** | People ordering food | Browse restaurants, search & filter, cart, coupons at checkout, order confirmation dialog, live order tracking with ETA, rate & review, address book, notifications inbox |
| **Driver** | Delivery riders | Go online/offline, accept/reject incoming orders (with countdown), live delivery status updates, earnings summary |
| **Merchant** | Restaurant owners | Kanban-style kitchen display (New → Preparing → Ready), accept/reject orders, menu management, sales reports, reply to customer reviews, store open/closed toggle |

---

## 🏗 Architecture

```
DeliveryApp/                     (this repo — Flutter monorepo, managed by Melos)
├── apps/
│   ├── customer_app/            Customer-facing app
│   ├── driver_app/               Driver-facing app
│   └── merchant_app/             Merchant-facing app
│
└── packages/                    Shared across all three apps
    ├── core/                     Result type, Failure hierarchy, API constants
    ├── network/                  Dio client, interceptors, WebSocket service
    ├── auth/                     Auth repository, login/register use cases
    ├── design_system/            Colors, spacing, radii, typography
    ├── shared_widgets/           AppButton, AppCard, StarRating, AppQuantityStepper…
    ├── state_machine/            Generic, typed order-state machine
    ├── sync/                     Offline request queue with retry + backoff
    ├── location/ · maps/         Geolocation & map helpers
    └── notifications/            Push-notification payload parsing

Delivery-go/                     (sibling repo — Go API server)
├── cmd/server/                  Fiber v3 HTTP server entry point
├── cmd/worker/                  Background outbox/event worker
├── internal/                    auth · order · restaurant · menu · driver ·
│                                 payment · wallet · coupon · review · tracking ·
│                                 notification · websocket · admin
└── database/                    Postgres schema + migrations
```

Every Flutter app talks to the **same** backend at `http://localhost:8080/api/v1`, and the same WebSocket hub at `ws://localhost:8080/ws`. There's one source of truth for order state — the server — and each app just renders it.

---

## 🚀 Quick Start

### 1. Start the backend

```bash
cd ../Delivery-go
docker compose up -d postgres redis nats
go run ./cmd/server
```

The API is now live at `http://localhost:8080` (check `curl http://localhost:8080/health`).

### 2. Bootstrap the Flutter workspace

```bash
dart pub global activate melos
melos bootstrap        # runs `flutter pub get` across every app + package
```

### 3. Run an app

```bash
cd apps/customer_app
flutter create . --platforms=web   # one-time, if web/ doesn't exist yet
flutter run -d chrome
```

Swap `customer_app` for `driver_app` or `merchant_app` to run the other roles. On the login screen, tap **"Try Demo Account"** — no need to remember credentials.

---

## 🧰 Tech Stack

| Layer | Choice |
|---|---|
| Client | Flutter 3.x, Dart 3.5+, `flutter_bloc`, `go_router`, `get_it` |
| Backend | Go 1.25, Fiber v3, Bun ORM |
| Database | PostgreSQL 16 |
| Cache / locks / idempotency | Redis 7 |
| Events / outbox | NATS |
| Realtime | Single WebSocket hub, room-based pub/sub |
| Monorepo tooling | Melos |

---

## 🗂 Everyday Commands

Run from the repo root (needs `melos bootstrap` once first):

```bash
melos run analyze   # dart analyze across every app + package
melos run format    # dart format, fails if anything needed formatting
melos run test      # flutter test across every package
melos run get       # flutter pub get everywhere
melos run clean     # flutter clean everywhere
```

---

## 🧭 What's real vs. what's next

In the spirit of not overselling a portfolio project:

**Solid and backend-verified:** order lifecycle & cancellation, coupons (with upfront min-purchase preview), reviews & ratings (with merchant replies), notifications, live ETA, merchant kitchen display, driver accept/reject flow, offline sync queue with retry.

**Known gaps, called out rather than hidden:**
- No real payment gateway integration — checkout supports cash/card selection but doesn't process real cards.
- Driver-side turn-by-turn navigation is a placeholder; ETA is computed (haversine + speed), not a routed map.
- No push notifications (FCM) wired up yet — in-app notification inbox only.

---

## 📄 License

No license has been specified for this project yet.
