---
name: release-build
description: Flutter 릴리즈 빌드 및 기기 설치 가이드. Android APK 릴리즈 빌드, iOS 릴리즈 빌드 후 실제 기기에 설치할 때 사용합니다. "APK 빌드해줘", "릴리즈 빌드해줘", "아이폰에 설치해줘", "안드로이드 APK 만들어줘" 등의 요청에 사용하세요.
---

# Release Build Skill

Flutter 앱의 릴리즈 빌드 생성 및 실제 기기 설치를 위한 가이드입니다.

## Android APK 릴리즈 빌드

### 빌드 명령어

```bash
# APK 빌드 (기본)
flutter build apk --release

# 특정 아키텍처만 빌드 (파일 크기 줄이기)
flutter build apk --release --target-platform android-arm64

# 앱번들 빌드 (Play Store 배포용)
flutter build appbundle --release
```

### 빌드 결과물 위치

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

### APK 설치 (연결된 기기)

```bash
# 빌드 후 바로 설치
flutter install --release

# 또는 adb 사용
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## iOS 릴리즈 빌드 및 기기 설치

### 사전 요구사항

1. **Apple Developer Account** 또는 **Personal Team** (무료 개발용)
2. **Xcode에서 기기 등록**: Xcode → Window → Devices and Simulators → 기기 연결
3. **프로비저닝 프로파일 설정**: Xcode에서 자동 서명 활성화

### 빌드 명령어

```bash
# 릴리즈 모드로 실제 기기에 설치
flutter run -d <device-id> --release
```

### 기기 ID 확인

```bash
flutter devices
```

출력 예시:
```
00008150-000641223AEA401C (mobile) • iPhone • ios
```

### 완전한 iOS 설치 워크플로우

```bash
# 1. 연결된 기기 확인
flutter devices

# 2. iOS 릴리즈 빌드 및 설치 (device-id 사용)
flutter run -d 00008150-000641223AEA401C --release
```

### 트러블슈팅

**서명 오류 발생 시**:
1. Xcode에서 프로젝트 열기: `open ios/Runner.xcworkspace`
2. Runner → Signing & Capabilities → Team 선택
3. "Automatically manage signing" 체크

**기기가 목록에 없을 경우**:
1. USB 케이블로 Mac에 연결
2. iPhone에서 "이 컴퓨터를 신뢰하시겠습니까?" → 신뢰
3. `flutter devices` 다시 실행

---

## 빠른 참조

| 플랫폼 | 명령어 | 결과물 |
|:---|:---|:---|
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android Bundle | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| iOS 기기 설치 | `flutter run -d <device-id> --release` | 기기에 직접 설치 |
