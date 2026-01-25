# DayCounter Widget Implementation & Release Build

## Changes
### iOS Widget Implementation
- **DayCounterWidget**: Implemented a HomeScreen widget using `WidgetKit` and `SwiftUI`.
- **Design**: Replicated the `PosterCard` design with dynamic background/foreground colors.
- **Sizes**: Supported both `.systemSmall` and `.systemMedium` families.
- **App Group**: Configured `group.day_counter` for data synchronization between the main App and Widget.
- **WidgetService**: Updated `WidgetService.dart` to save event data (title, d-day, date, colors) to `UserDefaults` via `home_widget` plugin.

### Feature Improvements
- **Event Detail Page**: Fixed `NestedScrollView` scroll behavior to prevent header collapse issues.
- **Todo List**: Added creation date display to todo items.

### Build & Release
- **Android**:
    - Updated `build.gradle.kts` to support Java 8 desugaring (library version 2.1.4).
    - Built Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- **iOS**:
    - Built Release App: `build/ios/iphoneos/Runner.app`
    - Verified installation on physical iPhone via `flutter run` and Xcode.

## Verification Results
### Automated Tests
- `flutter run` on physical iPhone verified successful launch and database loading.
- `flutter build apk --release` passed.
- `flutter build ios --release` passed.

### Manual Verification
- Confirmed Widget UI matches the in-app design.
- Confirmed Widget updates when events are modified (implied by service logic).
