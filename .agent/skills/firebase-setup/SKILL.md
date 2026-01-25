---
name: firebase-setup
description: Flutter 프로젝트에 Firebase를 설정하고 연동하는 가이드. Claude가 (1) Firebase 프로젝트 설정, (2) 설정 파일 생성(flutterfire configure), (3) 초기화 코드 작성, (4) iOS/Android 빌드 문제 해결이 필요할 때 사용.
---

# Firebase Setup

이 스킬은 Flutter 프로젝트에 Firebase를 설정하는 과정을 안내합니다.

## 1. 사전 준비 (Prerequisites)

먼저 Firebase CLI가 설치되어 있고 로그인되어 있는지 확인해야 합니다.

```bash
# 설치 확인
firebase --version

# 로그인 (안되어 있다면)
firebase login
```

CLI가 없다면: `npm install -g firebase-tools` 또는 `curl -sL https://firebase.tools | bash`

## 2. FlutterFire CLI 활성화

FlutterFire CLI는 Dart 전역 패키지로 실행하는 것이 좋습니다.

```bash
dart pub global activate flutterfire_cli
```

## 3. 프로젝트 설정 (Configure)

프로젝트 루트에서 다음 명령어를 실행하여 Firebase 프로젝트를 생성하거나 연결합니다.

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

> [!TIP]
> iOS 설정 중 에러가 발생하면 `gem install xcodeproj --user-install`을 실행해보세요. 상세한 iOS 설정 이슈는 [iOS Setup](references/ios.md)을 참고하세요.

## 4. 패키지 추가

`pubspec.yaml`에 필요한 Firebase 패키지를 추가합니다.

```yaml
dependencies:
  firebase_core: ^latest_version
  # 필요한 다른 패키지들 (analytics, auth, firestore 등)
```

## 5. 초기화 코드 (Initialization)

`lib/generated/firebase_options.dart` (또는 `lib/firebase_options.dart`)가 생성되었는지 확인하세요.
그 후 `main.dart`에 초기화 코드를 추가해야 합니다.

### [main.dart](file:///assets/init_code.dart)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ...
}
```

## 6. 플랫폼별 추가 설정

빌드 문제가 발생하면 플랫폼별 노트를 확인하세요.

- **Android**: [Android Setup](references/android.md) (google-services.json, minSdk 등)
- **iOS**: [iOS Setup](references/ios.md) (Podfile, GoogleService-Info.plist 등)
