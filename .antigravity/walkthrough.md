# Walkthrough - 릴리즈 빌드 및 설치 결과

Android용 APK 릴리즈 빌드를 완료하고, 연결된 iPhone 실기기에 릴리즈 모드로 앱을 설치 및 실행했습니다.

## 작업 결과

### 1. Android APK 빌드
- **명령**: `flutter build apk --release`
- **결과**: 빌드 성공
- **파일 경로**: `build/app/outputs/flutter-apk/app-release.apk`
- **파일 용량**: 65.4MB
- **특이사항**: 아이콘 트리 쉐이킹(Tree-shaking)을 통해 폰트 에셋 용량을 최적화했습니다.

### 2. iOS 실기기 설치
- **명령**: `flutter run -d 00008150-000641223AEA401C --release`
- **대상**: Kihoonee iPhone
- **결과**: 성공적으로 설치 및 실행됨
- **빌드 시간**: 332.0s
- **서명**: Xcode 프로젝트에 설정된 Development Team(G3578Y7NMA)을 사용하여 자동 서명 및 배포되었습니다.

## 확인 및 검증
- Android APK 파일이 지정된 위치에 생성된 것을 확인했습니다.
- 사용자의 iPhone에서 릴리즈 모드로 앱이 구동되는 것을 확인했습니다.
