# Implementation Plan - Release Build and Installation

Android용 APK 파일을 생성하고, 실기기 iPhone에 릴리즈 버전의 앱을 설치(배포)하는 작업을 수행합니다.

## Proposed Changes

### Android Build
- 명령: `flutter build apk --release`
- 결과물: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Installation
- 명령: `flutter run -d 00008150-000641223AEA401C --release`
- 대상: 사용자 iPhone (Kihoonee iPhone)
- 주의사항: 실기기 설치 시 Xcode에서 유효한 Provisioning Profile과 Signing이 설정되어 있어야 합니다.

## Verification Plan

### Manual Verification
- **Android**: 생성된 APK 파일 경로 확인.
- **iOS**: iPhone에서 앱이 릴리즈 모드로 정상 실행되는지 확인.
- **Log**: 빌드 과정에서 발생하는 서명 관련 오류나 설치 오류 체크.
