# ShopFlow — E-Commerce Mobile App

A modern, fully featured e-commerce app built with **Flutter**, **BLoC (Cubit)**, **Firebase** and the
[DummyJSON](https://dummyjson.com/products) REST API. English & Arabic (RTL), light & dark themes.

## ✨ Features

| | |
|---|---|
| 🔐 **Auth** | Firebase email/password — login, register (password strength), reset password |
| 🏠 **Home** | Promo carousel, flash deals with countdown, category chips, infinite product grid, shimmer loading |
| 🔎 **Search** | Debounced live search, recent & popular searches, sort / price range / rating filters |
| 🗂️ **Categories** | Category grid → paginated category pages |
| 📦 **Product details** | Image gallery with zoom, stock status, reviews summary, related products |
| ❤️ **Favorites** · 🛒 **Cart** | Quantity stepper, swipe-to-delete with undo, promo codes, free-shipping progress |
| 💰 **Checkout (demo)** | Addresses, delivery options, live card preview, order confirmation with confetti |
| 📍 **Addresses** · 📦 **Orders** | Manage addresses, order history & tracking timeline |
| 🔔 **Notifications** | Local push notifications + in-app inbox for order updates & offers |
| ☁️ **Cloud sync** | Cart, favorites, addresses & orders synced per user with Cloud Firestore (offline-first) |
| 🌐 **Localization** | English / العربية with full right-to-left layout |
| 🌙 **Dark mode** | Persisted theme preference |

Demo promo codes: `SHOP10`, `WELCOME`, `FLOW20` · Test card: `4242 4242 4242 4242`, any future date.

## 🧱 Architecture

```
lib/
├── core/          # theme, l10n, network (Dio), storage, services, utils, shared widgets
├── data/          # models + repositories (products API, auth, Firestore sync)
├── logic/         # Cubits (auth, home, search, cart, favorites, orders, address, notifications, theme, locale)
└── presentation/  # screens & widgets, one folder per feature
```

## 🚀 Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and run `flutter pub get`.
2. Firebase:
   - Create a project, enable **Authentication → Email/Password** and **Firestore Database**.
   - Run `flutterfire configure` to generate `lib/firebase_options.dart`.
   - Publish the rules in [`firestore.rules`](firestore.rules).
3. Generate the app icon and native splash:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```
4. Run: `flutter run`

## 🛠️ Tech stack

Flutter · flutter_bloc · Dio · Firebase Auth · Cloud Firestore · flutter_local_notifications ·
shared_preferences · cached_network_image · shimmer · google_fonts
