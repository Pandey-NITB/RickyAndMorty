# RickyAndMorty

Small SwiftUI iOS app for the Rick & Morty API assignment.

## Requirements

- iOS 15+
- Xcode 15+ / Swift 5
- SwiftUI
- async/await

## Architecture

The app is split into three folders that mirror Clean Architecture:

- `Domain`: framework-free models, repository protocols, and use cases.
- `Data`: API endpoints, DTOs, mapping, networking, cache, and favourites persistence.
- `Presentation`: SwiftUI views and `@MainActor` view models. Views stay passive and render state exposed by the view models.

Dependencies are injected through `AppContainer`. Production code does not use singletons for app services; `URLSession` is hidden behind `URLSessionProtocol`, so `NetworkService` can be unit tested with a mock session.

## Features

- Paginated character list with infinite scroll.
- Debounced name search.
- Status filter chips for Alive, Dead, and Unknown.
- Colour-coded status badges.
- Character detail screen with profile fields and episode name/air date.
- Favourite toggle persisted with `UserDefaults`, including list/detail sync after returning from detail.
- Last successful character pages cached in `UserDefaults` and used as an offline fallback.
- Episode details cached in `UserDefaults` and used as an offline fallback after a successful load.
- Avatar images cached with `URLCache` for faster repeat list/detail rendering.
- Skeleton/shimmer loading placeholders.
- Stable placeholder shown when a character image is missing or fails to load.
- Semantic/adaptive SwiftUI colours for Dark Mode.

## Tests

Covered areas:

- `CharacterListViewModel`: initial load, pagination, debounced search, stale request handling.
- `DefaultFetchCharactersUseCase`: repository call and returned result.
- `NetworkService`: successful decode, HTTP status mapping, decoding error mapping.

Run:

```sh
xcodebuild test \
  -project RickyAndMorty/RickyAndMorty.xcodeproj \
  -scheme RickyAndMorty \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Trade-offs

The cache is intentionally small and simple: it stores fetched character pages and episode payloads in `UserDefaults`, and uses `URLCache` for avatar images. For a production app I would move API payloads to a typed local persistence store with expiry and richer cache invalidation.

With more time, I would add richer empty/error states, UI tests, and snapshot tests for the character row badge/favourite combinations.
