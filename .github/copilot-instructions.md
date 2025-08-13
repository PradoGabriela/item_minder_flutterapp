# Item Minder Flutter App - AI Agent Instructions

## Architecture Overview

This is a Flutter inventory management app using a **dual-persistence architecture**:
- **Hive** for offline-first local storage (primary data source)
- **Firebase Realtime Database** for real-time sync across devices
- **Manager pattern** for all business logic and CRUD operations

The app starts at `StarterScreen` (group selection) → `BottomNavBar` → screens (Home, Shopping, Calendar, Profile).

## Critical Patterns

### Data Flow Architecture
```
UI Screens → Managers → Hive Boxes ↔ Firebase Listeners
```

- **Never bypass managers** - all data operations go through manager classes in `lib/base/managers/`
- **Hive is source of truth** - Firebase sync runs in background via listeners
- **Device ID tracking** - all changes track `lastUpdatedBy` for conflict resolution

### Manager Pattern (Essential)
All CRUD operations use dedicated managers:
- `ItemManager` - items CRUD, Firebase sync
- `GroupManager` - group management, member tracking  
- `BoxManager` - Hive box lifecycle (open/close/clear)
- `NotificationManager` - local notifications

Example pattern:
```dart
// ✅ Correct - use manager
ItemManager().addItem(newItem);

// ❌ Wrong - direct box access
BoxManager().itemBox.add(item);
```

### Hive Data Models
All models extend `HiveObject` with `@HiveType` and `@HiveField` annotations:
- `AppItem` (typeId: 0) - inventory items
- `AppNotification` (typeId: 1) - local notifications  
- `AppShopping` (typeId: 2) - shopping list items
- `AppGroup` (typeId: 3) - user groups

Code generation required: `flutter packages pub run build_runner build`

### Firebase Sync Architecture
- **Push changes**: Managers update Hive → Firebase via dedicated methods
- **Receive changes**: `FirebaseListeners` monitors changes → updates Hive
- **Conflict resolution**: Compare `lastUpdated` timestamps (substring 0-19)
- **Device filtering**: Skip updates from same `deviceId` to prevent loops

## Navigation & UI Patterns

### Bottom Navigation Structure
`BottomNavBar` manages 5 screens with conditional navigation bar:
- Index 0 (StarterScreen): No bottom nav shown
- Index 1+ (HomeScreen, Shopping, Calendar, Profile): Shows navigation

### Style System
Singleton `AppStyles()` class provides centralized theming:
- Primary color: `#FF914D` (orange)
- Use `AppStyles().getPrimaryColor()` for consistent theming
- Pre-defined text styles: `titleStyle`, `buttonStyle`, etc.

### Asset Management
Extensive asset system in `assets/`:
- `images/` - item category images (air freshener.png, etc.)
- `icons/` - app icons and category icons  
- `tutorial/` - onboarding assets

## Essential Development Commands

```bash
# Code generation (required after model changes)
flutter packages pub run build_runner build

# Clean build (if Hive issues)
flutter clean && flutter pub get

# Firebase debug
flutter run --debug  # Check debug prints for Firebase sync
```

## Firebase Listeners Behavior

The `FirebaseListeners.setupFirebaseListeners()` method:
- Monitors `groups` node for real-time updates
- Handles nested item updates within groups
- Automatically resolves conflicts using timestamps
- Manages item deletions when groups are removed

Debug prints prefixed with emojis indicate listener activity:
- 🆕 New data added
- 🔄 Data updated  
- 🗑️ Data deleted
- ❌ Errors

## Key Integration Points

### Device Management
- `DeviceId()` singleton generates unique device identifier
- Used for conflict resolution and change tracking
- Initialized in `main.dart` before other services

### Connectivity-Aware Sync
- `ConnectivityService` monitors network status
- Firebase operations only when online
- Hive ensures offline functionality continues

### Group-Based Architecture
Items belong to groups (`groupID` field). When navigating:
- Pass `currentGroupId` to screens requiring group context
- Filter operations by group for multi-tenant behavior

## Common Gotchas

1. **Bottom nav index**: StarterScreen is index 0 but shows no nav bar
2. **Firebase structure**: Items nested under `groups/{groupId}/itemsID/{itemId}`
3. **Timestamp comparison**: Always use `.substring(0, 19)` for date comparisons
4. **Code generation**: Required after any `@HiveField` changes
5. **Manager dependency**: Never skip managers - they handle Firebase sync automatically

## File Organization

- `lib/base/` - Core business logic (managers, models, widgets, styles)
- `lib/screens/` - UI screens (one per major user workflow)
- `lib/services/` - App-level services (connectivity, etc.)
- `lib/listeners/` - Firebase real-time listeners
