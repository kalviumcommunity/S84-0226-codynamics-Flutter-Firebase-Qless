# 🍜 Qless - Vendor App
Developed by Team **codynamics**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

Qless is a robust, real-time **Flutter + Firebase** application specifically designed for street-food vendors and high-traffic food stalls. It transforms chaotic manual queues into a streamlined digital experience, empowering vendors to manage orders, menus, and customer flow from a single handheld device.

---

## 📋 Table of Contents
- [The Problem](#-the-problem)
- [The Solution](#-the-solution)
- [System Architecture Overview](#-system-architecture-overview)
- [Database Schema](#-database-schema-cloud-firestore)
- [Core Data Models](#-core-data-models-entities)
- [Service Layer](#-service-layer-repositories)
- [State Management Strategy](#-state-management-strategy)
- [UI Component Structure](#-ui-component-structure)
- [Critical Business Logic](#-critical-business-logic)
- [Gradle & Android Build Setup](#-gradle--android-build-setup)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Getting Started](#-getting-started)
- [Step-by-Step Implementation](#-step-by-step-implementation)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🚩 The Problem
Street-food vendors often face significant operational challenges:
- **Queue Fatigue:** Customers get frustrated by long, unorganized lines and lack of transparency regarding order status.
- **Manual Errors:** Handwriting orders and manual token tracking often leads to mistakes in items or payment.
- **Scaling Issues:** During rush hours, managing incoming orders while focusing on cooking becomes overwhelming.
- **Menu Rigidness:** Updating prices or marking items as "Sold Out" is difficult to communicate to customers in real-time.

## ✨ The Solution
**Qless** provides a "Queue-less" experience through an integrated Vendor POS and Live Queue Management system:
- **Real-time Order Tracking:** Using Firebase Streams, orders move seamlessly from "Pending" to "Cooking" to "Ready" without manual refreshing.
- **Daily Token System:** Automated, lightweight token generation ensures customers know exactly when it's their turn.
- **Dynamic Menu Management:** Vendors can toggle item availability with a single switch, instantly updating the ordering interface.
- **Structured POS Interface:** A "Punch-In" screen optimized for speed, allowing vendors to take orders in seconds.

---

## 🏗 System Architecture Overview

We follow a clean, **Layered Architecture** to ensure modularity and scalability:

*   **UI Layer (Widgets):** Screens and reusable components built with Flutter's Material Design.
*   **State Layer (Providers):** Reactive state management using the `Provider` package (e.g., `CartProvider`, `OrdersProvider`).
*   **Data Layer (Repositories):** Abstracted logic for interacting with Cloud Firestore and Firebase Auth.
*   **Infrastructure:** Cloud backend services powered by Firebase for storage, authentication, and real-time synchronization.

---

## 💾 Database Schema (Cloud Firestore)

A NoSQL structure designed for high-concurrency read/write operations.

| Collection | Role | Document ID | Key Fields |
| :--- | :--- | :--- | :--- |
| `users` | Vendor Profiles | `uid` (Auth) | `shopName`, `ownerName`, `createdAt` |
| `menu_items` | Product Catalog | Auto-gen | `vendorId`, `name`, `price`, `category`, `isAvailable` |
| `orders` | Transactional Data | Auto-gen | `tokenNumber`, `status`, `totalAmount`, `isPaid`, `items` (Array) |

---

## 📦 Core Data Models (Entities)

Defined in `lib/models/` to ensure type safety across the application.

### 1. MenuItem Model
Handles the product details and Firestore conversions.
```dart
class MenuItem {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  MenuItem({required this.id, required this.name, required this.price, this.isAvailable = true});

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}
```

### 2. OrderItem & OrderModel
- **OrderItem:** Helper for capturing items within an order (Locks in price and name at order time).
- **OrderModel:** The main transaction entity tracking token number, total amount, and order status (`pending`, `cooking`, `ready`, `completed`).

---

## 🛠 Service Layer (Repositories)

This layer isolates Firebase logic from the UI, found in `lib/services/`.

- **AuthRepository:** Manages user sessions (`signIn`, `signOut`, `authStateChanges`).
- **MenuRepository:** 
    - `getMenuStream(vendorId)`: Fetch live menu updates for the POS.
    - `addMenuItem(item)`: Add new items to the vendor's catalog.
    - `updateItemAvailability(id, isAvailable)`: Simple toggle for "Sold Out" status.
- **OrderRepository:** 
    - `getLiveOrders(vendorId)`: Queries active orders sorted by `orderTime` (excl. completed).
    - `updateOrderStatus(orderId, newStatus)`: Moving from Pending -> Cooking -> Ready.

---

## 🎛 State Management Strategy

We utilize the **Provider** package for predictable state transitions:

1.  **CartProvider (Ephemeral State):** 
    - Manages the local "shopping cart" during the POS checkout process.
    - Handles logic like increments/decrements and total amount calculation.
2.  **OrdersProvider (Global State):** 
    - Listens to the `OrderRepository` stream.
    - Exposes categorized lists: `pendingOrders`, `cookingOrders`, and `readyOrders` for organized UI rendering.

---

## 📱 UI Component Structure

### 1. Live Queue (Home)
A centralized dashboard for order fulfilment:
- **Pending Tab:** New orders awaiting acceptance.
- **Cooking Tab:** Kitchen view for items currently being prepared.
- **Ready Tab:** Orders waiting at the counter for pickup.
- **OrderCardWidget:** Displays Token #, Items, and Total Price with "Advance Status" actions.

### 2. Punch-In (POS)
Optimized for rapid order entry:
- **Menu Grid:** Selectable items that instantly update the cart via `CartProvider`.
- **Cart Summary:** Quick overview of totals and a "Place Order" confirmation dialog.

### 3. Menu Management
Administrative tools for vendors:
- ListView of all menu items with instant status toggles and a "Add Item" interface.

---

## 🧠 Critical Business Logic

### A. Token Generation
To maintain a simple yet effective queue, we use a pseudo-unique token system:
`DateTime.now().millisecondsSinceEpoch % 1000`
This generates a 3-digit token suitable for daily operations without complex database transactions.

### B. Price Security
Totals are calculated within the `CartProvider` using a `quantity * price` loop for every item in the cart, ensuring the value sent to Firestore is accurate at the moment of the transaction.

---

## � Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>=3.0.0) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (>=2.17.0) - Comes bundled with Flutter
- **Firebase Account** - [Create one here](https://firebase.google.com/)
- **IDE:** VS Code or Android Studio with Flutter plugins
- **Git** for version control

---

## 🔧 Installation

### 1. Clone the Repository
```bash
git clone git@github.com:kalviumcommunity/S84-0226-codynamics-Flutter-Firebase-Qless.git
cd S84-0226-codynamics-Flutter-Firebase-Qless
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configure Firebase
```bash
flutterfire configure
```

This will:
- Create a new Firebase project or select an existing one
- Register your Flutter app with Firebase
- Download the configuration files

#### Enable Required Firebase Services
In the [Firebase Console](https://console.firebase.google.com/):
1. **Authentication:** Enable Email/Password sign-in method
2. **Cloud Firestore:** Create a database in production mode
3. **Set Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /menu_items/{itemId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Run the App
```bash
flutter run
```

---

## � Gradle & Android Build Setup

This project uses **Gradle Kotlin DSL** (`.gradle.kts`) for Android builds. Below is everything you need to know to build, run, and troubleshoot the Android side.

### Gradle Version & Plugin Stack

| Component | Version |
|---|---|
| Android Gradle Plugin (AGP) | 8.11.1 |
| Kotlin | 2.2.20 |
| Google Services Plugin | 4.4.4 |
| Firebase BoM | 34.9.0 |
| Java Compatibility | 17 |
| Compile SDK | Matches Flutter SDK |
| Min SDK | Matches Flutter SDK |

### Project Structure

```
android/
├── settings.gradle.kts      # Plugin management & repository config
├── build.gradle.kts          # Root build file (repositories, clean task)
├── gradle.properties         # JVM args & AndroidX config
├── local.properties          # Local SDK paths (auto-generated, do NOT commit)
├── app/
│   ├── build.gradle.kts      # App-level plugins, dependencies, signing
│   └── google-services.json  # Firebase config (do NOT commit)
└── gradle/
    └── wrapper/              # Gradle wrapper (auto-managed)
```

### Key Configuration Files

#### `android/settings.gradle.kts`
Manages plugin versions and Flutter SDK integration:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.4" apply false
}
```

#### `android/app/build.gradle.kts`
App configuration with Firebase:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.Codynamics.Qless"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

#### `android/gradle.properties`
JVM memory settings for stable builds:
```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
```

### Building for Mobile

#### Debug Build
```bash
flutter run                    # Run on connected device/emulator
flutter build apk --debug      # Generate debug APK
```

#### Release Build
```bash
flutter build apk --release    # Generate release APK
flutter build appbundle         # Generate AAB for Play Store
```

Release APK output: `build/app/outputs/flutter-apk/app-release.apk`
AAB output: `build/app/outputs/bundle/release/app-release.aab`

#### Profile Build (for performance testing)
```bash
flutter run --profile          # Run with performance profiling
```

### Running Gradle Tasks Directly

```bash
# From project root
cd android

# Clean build artifacts
./gradlew clean

# Build debug APK via Gradle
./gradlew assembleDebug

# Build release APK via Gradle
./gradlew assembleRelease

# Check dependencies
./gradlew app:dependencies

# Run lint checks
./gradlew lint
```

On Windows, use `gradlew.bat` instead of `./gradlew`.

### Troubleshooting

| Issue | Fix |
|---|---|
| `Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'` | Run `cd android && gradlew.bat clean` then `flutter pub get` |
| Out of memory during build | Increase heap in `gradle.properties`: `-Xmx8G` (already configured) |
| `google-services.json` not found | Place your Firebase config at `android/app/google-services.json` |
| Kotlin version mismatch | Ensure `org.jetbrains.kotlin.android` version in `settings.gradle.kts` matches your Kotlin install |
| `flutter.sdk not set` | Run `flutter doctor` — `local.properties` is auto-generated |
| Gradle sync fails after Flutter upgrade | Delete `android/.gradle/` and `build/` folders, then rebuild |
| `Namespace not specified` | Already set to `com.Codynamics.Qless` in `app/build.gradle.kts` |

### Adding New Firebase Services

To add a new Firebase dependency (e.g., Firestore, Auth):

1. Add the Flutter package:
   ```bash
   flutter pub add cloud_firestore
   ```
2. Optionally add the native Android dependency in `android/app/build.gradle.kts`:
   ```kotlin
   dependencies {
       implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
       implementation("com.google.firebase:firebase-analytics")
       implementation("com.google.firebase:firebase-firestore")  // new
   }
   ```
3. Run `flutter pub get` and rebuild.

> **Note:** Most Firebase Flutter plugins auto-include native dependencies. The manual step above is only needed if you use Firebase Android APIs directly.

---

## �🚀 Getting Started

### First Time Setup

1. **Create Vendor Account:**
   - Launch the app and navigate to the sign-up screen
   - Enter your shop name and owner details
   - Complete authentication

2. **Setup Your Menu:**
   - Go to "Menu Management" tab
   - Add your food items with names and prices
   - Categorize items for easier organization

3. **Start Taking Orders:**
   - Switch to "Punch-In" (POS) tab
   - Select items to build an order
   - Confirm and generate a token for the customer

4. **Manage the Queue:**
   - Monitor orders in the "Live Queue" tab
   - Move orders through: Pending → Cooking → Ready → Completed

---

## 🚀 Step-by-Step Implementation

1.  **Initialize:** `flutter create qless` and configure Firebase via FlutterFire CLI.
2.  **Models:** Implement the `MenuItem` and `OrderModel` classes.
3.  **Core Services:** Setup `MenuRepository` and ensure "Menu Management" is functional first.
4.  **POS Logic:** Build the `CartProvider` and "Punch-In" screen.
5.  **Kitchen Workflow:** Connect the `StreamBuilder` in the "Live Queue" screen to track order statuses in real-time.

---

## 🤝 Contributing

We welcome contributions from the community! To contribute:

1. **Fork the Repository**
2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit Your Changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to the Branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open a Pull Request**

### Code Style Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex business logic
- Ensure all tests pass before submitting PR

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

Developed with ❤️ by **Team codynamics**

### Contact & Support
- 📧 Report issues on [GitHub Issues](https://github.com/kalviumcommunity/S84-0226-codynamics-Flutter-Firebase-Qless/issues)
- 💬 For questions and discussions, use [GitHub Discussions](https://github.com/kalviumcommunity/S84-0226-codynamics-Flutter-Firebase-Qless/discussions)

---

© 2025 Developed by **Team codynamics**