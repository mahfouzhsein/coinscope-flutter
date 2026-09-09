# CoinScope Mobile

A native Flutter companion to the [CoinScope web app](https://coinscope-kappa.vercel.app/). It preserves the original product's dark slate surfaces, cyan-to-indigo identity, compact market cards, and clear gain/loss language while adapting the experience to Android and iOS navigation.

[Download the latest Android demo APK](https://github.com/mahfouzhsein/coinscope-flutter/releases/latest/download/CoinScope-Android.apk)

## What it includes

- Global market cap, 24-hour volume, Bitcoin dominance, and active coin metrics
- Trending assets and market-cap leaders
- Searchable, sortable, paginated markets in USD, EUR, or GBP
- Persistent currency, page-size, and watchlist preferences
- Coin detail views with 24H, 7D, 30D, 90D, and 1Y price charts
- Pull-to-refresh, loading skeletons, empty states, rate-limit messaging, and retry actions
- Cached remote coin imagery and accessible watchlist controls

No API key or secret is required. Market data comes directly from CoinGecko's public API, so public rate limits still apply.

## Architecture

The app uses feature-first folders with a small data/domain/presentation split. `flutter_riverpod` owns asynchronous market state and persisted preferences, `cached_network_image` handles coin artwork, and `shared_preferences` stores local choices.

```mermaid
flowchart TD
    UI[Flutter screens] --> Providers[Riverpod providers]
    Providers --> API[CoinGecko client]
    Providers --> Storage[Local preferences]
    API --> PublicAPI[Keyless CoinGecko API]
```

## Run locally

Install the current stable Flutter SDK, connect an Android device/emulator or iOS simulator, then run:

```bash
flutter pub get
flutter run
```

Quality checks:

```bash
flutter analyze
flutter test
```

## Recruiter demo builds

Every push is checked by GitHub Actions, produces an APK artifact, and refreshes the installable `android-demo` release. Pushing a version tag such as `v1.0.0`, or manually running the **Publish Android demo** workflow, creates a versioned GitHub Release.

Android may ask the reviewer to allow installation from the browser or file manager. iOS distribution requires Apple signing; TestFlight can be added later without changing the Flutter application architecture.

## Platform identifiers

- Android application ID: `com.husseinmahfouz.coinscope`
- iOS bundle ID: `com.husseinmahfouz.coinscope`

This project is independently maintained from the CoinScope web repository.
