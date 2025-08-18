# 🛠️ Development Guide

This guide provides detailed information for developers who want to contribute to or understand the Item Minder Flutter app architecture.

## 🏗️ Architecture Overview

### Dual-Persistence Architecture

The app implements a sophisticated dual-persistence system:

```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   UI Screens    │───▶│    Managers      │───▶│   Hive Boxes     │
│                 │    │                  │    │  (Local Store)   │
│ - HomeScreen    │    │ - ItemManager    │    │                  │
│ - Shopping      │    │ - GroupManager   │    │ - AppItem        │
│ - Calendar      │    │ - BoxManager     │    │ - AppGroup       │
│ - Profile       │    │ - etc.           │    │ - AppShopping    │
└─────────────────┘    └──────────────────┘    └──────────────────┘
                                │                        │
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌──────────────────┐
                       │ Firebase Managers│◀──▶│ Firebase Listeners│
                       │                  │    │                  │
                       │ - Firebase       │    │ - Real-time sync │
                       │   Item Manager   │    │ - Conflict res.  │
                       │ - Firebase       │    │ - Member mgmt    │
                       │   Group Manager  │    │                  │
                       └──────────────────┘    └──────────────────┘
                                │                        │
                                └────────┬───────────────┘
                                         ▼
                              ┌──────────────────┐
                              │ Firebase Realtime│
                              │    Database      │
                              │                  │
                              │ - groups/        │
                              │   - {groupId}/   │
                              │     - itemsID/   │
                              │     - members[]  │
                              └──────────────────┘
```

### Key Design Principles

1. **Manager Pattern**: All business logic is encapsulated in manager classes
2. **Single Source of Truth**: Hive serves as the primary data source
3. **Firebase as Sync Layer**: Real-time synchronization happens in background
4. **Conflict Resolution**: Timestamp-based conflict resolution
5. **Device Tracking**: Each change tracks the originating device
6. **Explicit Membership**: Users only sync groups they've explicitly joined

## 📦 Data Models

### Hive Type IDs
- `AppItem` (typeId: 0) - Inventory items
- `AppNotification` (typeId: 1) - Local notifications
- `AppShopping` (typeId: 2) - Shopping list items
- `AppGroup` (typeId: 3) - User groups

### Model Relationships
```
AppGroup
├── groupID: String (primary key)
├── members: List<String>
├── itemsID: List<String> ──┐
└── memberName: String       │
                             │
AppItem                      │
├── itemID: String ──────────┘
├── groupID: String (foreign key)
├── quantity: int
├── minQuantity: int
├── lastUpdated: DateTime
└── lastUpdatedBy: String
```

## 🔄 Data Flow Patterns

### 1. Local Operations (Offline-First)
```dart
// User action → Manager → Hive Box → UI Update
await ItemManager().addCustomItem(
  // ... item data
);
```

### 2. Firebase Sync (Background)
```dart
// Manager → Firebase Manager → Firebase Database
FirebaseItemManager().addItemToFirebase(groupID, item, itemID);
```

### 3. Real-time Updates (From Other Devices)
```dart
// Firebase Listener → Hive Update → UI Refresh
FirebaseListeners.setupFirebaseListeners();
```

## 🔧 Manager Classes

### ItemManager
- **Purpose**: Manages all item CRUD operations
- **Key Methods**:
  - `addCustomItem()` - Creates new items
  - `editItem()` - Updates existing items
  - `removeItem()` - Deletes items
  - `findItemByID()` - Locates items for Firebase listeners

### GroupManager
- **Purpose**: Handles group lifecycle and membership
- **Key Methods**:
  - `createGroup()` - Creates new groups
  - `joinGroup()` - Joins existing groups
  - `leaveGroup()` - Leaves groups
  - `addItemToGroup()` - Associates items with groups

### BoxManager
- **Purpose**: Manages Hive box lifecycle
- **Singleton Pattern**: Ensures single instance of each box
- **Methods**:
  - `openBoxes()` - Initialize all Hive boxes
  - `closeBoxes()` - Clean shutdown
  - Access properties: `itemBox`, `groupBox`, etc.

### Firebase Managers
- **FirebaseItemManager**: Handles item sync to Firebase
- **FirebaseGroupManager**: Manages group data in Firebase
- **Separation of Concerns**: Keep Firebase logic separate from local logic

## 🎧 Firebase Listeners

### FirebaseListeners Class
Located in `lib/listeners/firebase_listeners.dart`

#### Key Responsibilities:
1. **Group Change Detection**: Monitors `groups` node for updates
2. **Member Management**: Handles joins/leaves in real-time
3. **Item Synchronization**: Syncs item changes across devices
4. **Conflict Resolution**: Uses timestamps to resolve conflicts
5. **Self-Removal Detection**: Removes local data when user is kicked out

#### Listener Types:
- `onChildChanged` - Handles group updates (members, items, metadata)
- `onChildRemoved` - Handles group deletions

#### Debug Output:
The listeners provide comprehensive debug logging:
- 🔥 Firebase listener triggered
- 👥 Member list changes
- 🆕 New data added
- 🔄 Data updated
- 🗑️ Data deleted
- ❌ Errors

## 🔀 Conflict Resolution

### Timestamp-Based Resolution
```dart
bool _shouldUpdateGroup(AppGroup local, Map<String, dynamic> firebase) {
  var compareTo = local.lastUpdatedDateString
      .substring(0, 19)
      .compareTo(firebase['lastUpdatedDateString'].substring(0, 19));
  
  return compareTo < 0; // Local is older, should update
}
```

### Device ID Tracking
- Each device has a unique ID generated by `DeviceId()`
- Every change records `lastUpdatedBy` field
- Prevents infinite update loops between devices

### Update Priority:
1. **Explicit Changes**: Member additions/removals always processed
2. **Timestamp Comparison**: For other changes, newer wins
3. **Local Fallback**: If comparison fails, keep local data

## 🏗️ UI Architecture

### Navigation Structure
```
StarterScreen (index: 0) ──┐
                           │
BottomNavBar ──────────────┘
├── HomeScreen (index: 1)
├── ShoppingScreen (index: 2)
├── CalendarScreen (index: 3)
└── ProfileScreen (index: 4)
```

### State Management
- **Provider Pattern**: Uses ChangeNotifier for local state
- **Manager Singletons**: Global state through manager classes
- **Hive Listeners**: UI updates when Hive data changes

### Styling System
- **Centralized**: `AppStyles()` singleton class
- **Primary Color**: `#FF914D` (orange theme)
- **Consistent**: All UI components use same style system

## 📱 Platform-Specific Code

### Android Configuration
- **Package**: `com.example.item_minder_flutterapp`
- **Min SDK**: 21 (Android 5.0)
- **Firebase**: Uses `google-services.json`

### iOS Configuration
- **Bundle ID**: `com.example.itemMinderFlutterapp`
- **Min iOS**: 12.0
- **Firebase**: Uses `GoogleService-Info.plist`

## 🧪 Testing Strategy

### Unit Tests
- Test manager classes in isolation
- Mock Firebase dependencies
- Verify Hive operations

### Integration Tests
- Test complete user workflows
- Firebase sync scenarios
- Offline/online transitions

### Testing Firebase Listeners
```dart
// Simulate Firebase changes
await FirebaseDatabase.instance.ref('groups/testGroupId').set({
  'members': ['user1', 'user2'],
  'lastUpdatedBy': 'differentDevice',
  'lastUpdatedDateString': DateTime.now().toString(),
});

// Verify local Hive updates
```

## 🚨 Common Pitfalls

### 1. Bypassing Managers
```dart
// ❌ Wrong - direct box access
BoxManager().itemBox.add(item);

// ✅ Correct - use manager
ItemManager().addCustomItem(/* ... */);
```

### 2. Firebase Loop Creation
```dart
// Always check device ID before processing
if (data['lastUpdatedBy'] == DeviceId().getDeviceId()) {
  return; // Skip own changes
}
```

### 3. Code Generation
```bash
# Required after any @HiveField changes
flutter packages pub run build_runner build
```

### 4. Timestamp Comparison
```dart
// Always use substring(0, 19) for date comparison
var compareTo = local.lastUpdated
    .toString()
    .substring(0, 19)
    .compareTo(firebase.toString().substring(0, 19));
```

## 🔧 Development Workflow

### 1. Setting Up Development Environment
```bash
git clone <repo>
cd item_minder_flutterapp
flutter pub get
flutter packages pub run build_runner build
```

### 2. Making Changes to Data Models
```bash
# Edit model files (*.dart with @HiveType)
flutter packages pub run build_runner build
```

### 3. Testing Firebase Integration
```bash
flutter run --debug
# Monitor debug console for Firebase sync logs
```

### 4. Debugging Hive Issues
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 📚 Additional Resources

### Code Documentation
- Manager classes have comprehensive inline documentation
- Firebase listeners include detailed comments
- Model classes document field purposes

### Debug Utilities
- Enable debug prints with `kDebugMode`
- Firebase listeners use emoji prefixes for easy filtering
- Device ID visible in debug logs

### Performance Considerations
- Hive operations are synchronous and fast
- Firebase listeners are optimized for minimal data transfer
- UI updates are batched through Flutter's rendering system

## 🤝 Contributing Guidelines

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comprehensive comments for complex logic
- Include debug prints for troubleshooting

### Testing Requirements
- Unit tests for new manager methods
- Integration tests for Firebase interactions
- Manual testing for UI changes

### Documentation
- Update README.md for user-facing changes
- Update this development guide for architecture changes
- Add inline documentation for new public methods

### Pull Request Process
1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Submit PR with detailed description
5. Address review feedback
6. Squash commits before merge

---

This development guide should be updated as the architecture evolves. For questions about specific implementations, refer to the inline documentation in the codebase.
