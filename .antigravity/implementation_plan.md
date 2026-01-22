# 릴리즈 빌드 크래시 분석 및 수정

릴리즈 빌드가 크래시되는 이유는 **`pubspec.yaml`에 Firebase가 포함되어 있지만 초기화되지 않았고**, 필요한 설정 파일들이 누락되었기 때문입니다.

## 원인
1. **설정 파일 누락**:
   - `ios/Runner/GoogleService-Info.plist` 누락
   - `android/app/google-services.json` 누락
   - `lib/firebase_options.dart` 누락
2. **초기화 코드 누락**:
   - `lib/main.dart`에서 `Firebase.initializeApp()`이 호출되지 않음

## 사용자 조치 필요
> [!IMPORTANT]
> `flutterfire configure`를 실행하여 설정 파일과 `firebase_options.dart`를 생성해야 합니다.

터미널에서 다음 명령어를 실행하세요:
```bash
flutterfire configure
```
또는 수동으로 `GoogleService-Info.plist`를 `ios/Runner/`에, `google-services.json`을 `android/app/`에 배치하고 `firebase_options.dart`를 생성하세요.

## 변경 제안

### 1. Main에서 Firebase 초기화
`firebase_options.dart`가 준비되면 `main.dart`를 수정하여 Firebase를 초기화합니다.

#### [MODIFY] [main.dart](file:///Users/kihoonee/flutter/day_counter/lib/main.dart)
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure로 생성됨

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  // ...
}
```

## 검증 계획

### 자동 검증
1. `flutter build ios --release` (또는 android) 실행.
2. `flutter run --release`를 실행하여 앱이 크래시 없이 실행되는지 확인.

### 수동 검증
1. Firebase 콘솔에서 Analytics 이벤트가 표시되는지 확인 (선택 사항).
