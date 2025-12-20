# KeepFresh

A modern iOS app for managing grocery inventory and tracking food expiration dates. KeepFresh helps reduce food waste by providing intelligent consumption predictions, shopping list management, and timely expiration reminders.

## Screenshots

| Today | Kitchen | Shopping | Search |
|:-----:|:-------:|:--------:|:------:|
| ![Today](screenshots/today.png) | ![Kitchen](screenshots/kitchen.png) | ![Shopping](screenshots/shopping.png) | ![Search](screenshots/search.png) |

## Features

- **Expiry Tracking** - Monitor food expiration dates with visual progress indicators and urgency levels (critical, attention, good)
- **Smart Storage** - Organize items by storage location (Pantry, Fridge, Freezer) with location-specific statistics
- **Shopping Mode** - Interactive shopping experience with category-based organization and completion tracking
- **Barcode Scanning** - Quickly add products by scanning barcodes
- **AI Suggestions** - Get intelligent recommendations for shopping items based on consumption patterns
- **Push Notifications** - Receive timely reminders about expiring items with quick actions
- **UK Supermarket Integration** - Product database featuring Tesco, Sainsbury's, M&S, Aldi, Lidl, Morrisons, Asda, and Co-op

## Requirements

- iOS 26.0+
- Xcode 16+
- Swift 6.2

## Architecture

KeepFresh uses a modular Swift Package Manager architecture with the `@Observable` pattern for state management.

### Project Structure

```
keepfresh-ios/
├── App/                     # Main app entry point
├── Packages/
│   ├── Models/              # Data models and caching
│   ├── Network/             # API client
│   ├── Authentication/      # Supabase auth
│   ├── Environment/         # State management
│   ├── Router/              # Navigation
│   ├── DesignSystem/        # UI components and tokens
│   ├── Notifications/       # Push notification handling
│   └── Features/
│       ├── TodayUI/         # Expiry overview
│       ├── SearchUI/        # Product search
│       ├── KitchenUI/       # Storage locations
│       ├── ShoppingUI/      # Shopping list
│       ├── BarcodeUI/       # Barcode scanner
│       └── SharedUI/        # Shared components
└── NotificationServiceExtension/
```

### Swift Packages

The app is structured as a monorepo with modular SPM packages. Each package has a focused responsibility:

#### Core Packages

| Package | Description |
|---------|-------------|
| **Models** | Data models (`InventoryItem`, `ShoppingItem`, `Product`, `StorageLocation`) with `Codable`/`Sendable` conformance. Includes file-based caching (`InventoryCache`, `ShoppingCache`, `SuggestionsCache`). |
| **Network** | HTTP client (`APIClient`) and API definitions (`KeepFreshAPI`). Handles authentication token injection and JSON encoding/decoding. |
| **Authentication** | Supabase integration for anonymous authentication with PKCE flow. Manages JWT tokens via Keychain storage. |
| **Environment** | Observable state managers (`Inventory`, `Shopping`, `RecentlyConsumed`) injected via SwiftUI's `@Environment`. |
| **Router** | Navigation state management with `RouterDestination` enum for type-safe navigation. |

#### UI Packages

| Package | Description |
|---------|-------------|
| **DesignSystem** | Color palette, typography (Shrikhand font), and reusable UI components. |
| **TodayUI** | Main expiry overview showing items sorted by consumption urgency. |
| **SearchUI** | Product search with debouncing, pagination, and barcode lookup. |
| **KitchenUI** | Storage location views (Pantry, Fridge, Freezer) with location statistics. |
| **ShoppingUI** | Shopping list management and interactive Shopping Mode. |
| **BarcodeUI** | Camera-based barcode scanning using CodeScanner. |
| **SharedUI** | Shared components like item cards and empty states. |

#### Supporting Packages

| Package | Description |
|---------|-------------|
| **Notifications** | Push notification handling with action categories (mark open, mark done, move to location). |
| **Extensions** | Utility extensions for `Date`, `Color`, `Array`. |
| **Intelligence** | Consumption prediction and usage percentage calculations. |
| **Utils** | General utilities. |

### Adding a New Package

1. Create a new directory under `Packages/`
2. Add `Package.swift` with dependencies on other local packages as needed
3. Add the package to the main Xcode project
4. Import in consuming packages or the main app

### Key Patterns

- **Observable Pattern** - Swift 6's `@Observable` for reactive state management
- **Environment Injection** - SwiftUI's `@Environment` for dependency injection across the view hierarchy
- **Modular Packages** - Clean separation of concerns enabling independent development and testing
- **File-based Caching** - JSON caching in the Documents directory for offline support and performance

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [Supabase](https://github.com/supabase/supabase-swift) | 2.34.0 | Authentication |
| [CodeScanner](https://github.com/twostraws/CodeScanner) | 2.5.0 | Barcode scanning |

## Getting Started

1. Clone the repository
2. Open `KeepFresh.xcodeproj` in Xcode
3. Build and run on a device or simulator running iOS 26+

## License

[Add license information]
