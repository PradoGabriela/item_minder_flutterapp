
# Item Minder - Flutter App Documentation

## Overview
Item Minder is a Flutter-based mobile application designed to help users organize, track, and manage items across different categories, groups, and shopping lists. 
It integrates with Firebase for real-time data synchronization and uses Hive for efficient offline storage.

Key features include:
- Create and manage groups of items.
- Organize items by categories and types.
- Add, edit, and delete items with images.
- Maintain shopping lists.
- View items on a calendar.
- Receive notifications for item-related events.
- Offline-first architecture with Hive DB.
- Real-time updates with Firebase.

---

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Built-in Flutter stateful widgets + managers.
- **Database (local):** Hive
- **Backend:** Firebase (Firestore, Authentication, Storage)
- **Cloud Functions:** (if configured)
- **Other services:** Firebase Messaging for notifications

---

## Project Structure

```
lib/
 ├── main.dart                   # Entry point
 ├── device_id.dart              
 ├── firebase_options.dart        # Firebase configuration
 ├── base/                        # Core business logic and shared components
 │   ├── categories.dart
 │   ├── hiveboxes/               # Local Hive data models
 │   ├── managers/                # Data managers (items, groups, notifications, etc.)
 │   ├── res/                     # Styles and resources
 │   └── widgets/                 # Reusable UI widgets
 ├── listeners/                   # Firebase listeners for real-time updates
 ├── screens/                     # UI screens (add item, edit item, shopping, etc.)
 └── services/                    # App services (e.g., connectivity)
```

### Notable Components
- **Hive Boxes:** Used for persisting data locally (group, item, shopping, notification).
- **Managers:** Encapsulate CRUD operations and sync logic with Firebase.
- **Widgets:** Modular and reusable UI building blocks.
- **Screens:** Each screen corresponds to a specific user workflow.

---

## Installation & Setup

### Prerequisites
- Flutter SDK installed
- Dart SDK installed
- Firebase project created and configured
- Android Studio / VS Code (recommended)

### Steps
1. **Clone the repository:**
   ```bash
   git clone <repo_url>
   cd item_minder_flutterapp
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase:**
   - Ensure `firebase_options.dart` matches your Firebase project settings.
   - Add Android and iOS Firebase configuration files (`google-services.json` and `GoogleService-Info.plist`) to the correct locations.

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## Features & Workflows

### 1. Item Management
- Add new items with details (title, category, type, image).
- Edit or delete existing items.
- Assign items to groups.

### 2. Group Management
- Create and join groups.
- Share items across groups.

### 3. Shopping List
- Add items to a shopping list.
- Mark items as purchased.

### 4. Calendar View
- See upcoming item-related events.

### 5. Notifications
- Push notifications for important events.
- Local notifications for offline reminders.

---

## Development Guidelines

- **Naming conventions:** Follow Dart and Flutter best practices (`lowerCamelCase` for variables/functions, `UpperCamelCase` for classes).
- **State management:** Use managers for business logic; avoid putting logic directly in widgets.
- **UI:** Use reusable widgets from `base/widgets/` to maintain design consistency.
- **Persistence:** Use Hive for local caching and Firebase for sync.
- **Testing:** Place tests in `/test` folder; aim for unit tests for managers and integration tests for workflows.

---

## Future Enhancements
- User authentication & profiles
- Advanced item search and filtering
- Barcode scanning for item input
- Multi-language support
- Dark mode
