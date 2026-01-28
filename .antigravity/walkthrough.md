# 의존성 업데이트 완료 보고서

iOS/Android 최신 OS 지원 및 모든 패키지를 최신 버전으로 업데이트했습니다.

---

## 업데이트 요약

### 플랫폼 설정
| 플랫폼 | 이전 | 이후 |
| :--- | :--- | :--- |
| iOS Deployment Target | 15.0 | **16.0** |
| Android minSdk | flutter.minSdkVersion | **24** |
| Android targetSdk | flutter.targetSdkVersion | **35** |

### Major 의존성 변경
| 패키지 | 이전 | 이후 |
| :--- | :--- | :--- |
| firebase_core | 3.15.2 | **4.4.0** |
| firebase_analytics | 11.6.0 | **12.1.1** |
| firebase_messaging | 15.2.10 | **16.1.1** |
| firebase_remote_config | 5.5.0 | **6.1.4** |
| google_mobile_ads | 5.2.0 | **7.0.0** |
| flutter_local_notifications | 19.5.0 | **20.0.0** |
| image_cropper | 8.1.0 | **11.0.0** |
| home_widget | 0.7.0 | **0.9.0** |
| hooks | 0.20.5 | **1.0.0** |

---

## 코드 수정 필요했던 부분

### [notification_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/notification_service.dart)

`flutter_local_notifications` 20.0.0에서 positional → named parameters로 변경:

```diff
- await plugin.initialize(initializationSettings);
+ await plugin.initialize(settings: initializationSettings);

- await plugin.zonedSchedule(id, title, body, date, details, ...);
+ await plugin.zonedSchedule(id: id, title: title, body: body, 
+   scheduledDate: date, notificationDetails: details, ...);

- await plugin.cancel(id);
+ await plugin.cancel(id: id);
```


---

## 라이브러리 교체 (Verification)

**[UPDATE] image_cropper → crop_your_image 교체**
- 이유: Android 네이티브 크래시 이슈 해결 및 iOS/Android UI 통일
- 변경사항:
  - `image_cropper` 제거
  - `crop_your_image` 추가
  - `AndroidManfiest.xml`에서 `UCropActivity` 제거
  - `AndroidManfiest.xml`에서 `UCropActivity` 제거
  - `ImageService`를 Flutter Widget(`_CropPage`) 기반으로 재작성

## 버그 수정 (Bug Fixes)

### iOS 실시간 사진 미리보기 이슈 수정
- **증상**: iOS에서 사진 변경 시 즉시 반영되지 않고 이전 이미지가 보이거나 변경되지 않음.
- **원인**: 
  1. `EventDetailPage`가 `EditTab`의 사진 변경 상태(`_photoPath`)를 전달받지 못해 `PosterCard`에 기존 경로(`event.photoPath`)를 계속 주입함.
  2. Flutter `Image.file` 위젯이 동일 경로의 파일 내용 변경을 즉시 감지하지 못하고 캐싱된 이미지를 보여줌.
- **해결**:
  1. **State Lifting**: `EventDetailPage`에 `_previewPhotoPath` 상태 추가 및 `EditTab`의 `onPhotoChanged` 콜백 연결.
  2. **Cache Eviction**: 사진 변경 시 이전 파일 경로에 대해 `FileImage(...).evict()` 호출로 캐시 삭제.
  3. **Force Rebuild**: `PosterCard` 이미지 위젯에 `key: ValueKey(photoPath)`를 부여하여 강제 리빌드 유도.

### 새 이벤트 등록 화면 사진 기능 추가
- **요청**: 새 기념일 등록 시 사진을 추가하는 UI가 누락됨.
- **해결**: `EventEditPage`에 `EditTab`과 동일한 사진 선택/크롭/삭제 로직 및 UI 구현. 이제 이벤트를 생성할 때부터 사진을 등록할 수 있습니다.

### 앱 세로 모드 고정
- **요청**: 앱을 세로 모드로 고정해달라.
- **해결**: `main.dart` 도입부에 `SystemChrome.setPreferredOrientations`를 사용하여 가로 모드 회전을 방지했습니다.

## 릴리즈 빌드 완료 (Release Builds)

### Android
- **APK 생성**: `build/app/outputs/flutter-apk/app-release.apk`
- **상태**: 릴리즈 사이닝 키스토어 설정에 따라 서명됨 (설정되어 있다고 가정).

### iOS
- **설치**: Kihoonee iPhone (실기기)에 릴리즈 모드로 설치 및 실행 완료.

## 빌드 검증

| 플랫폼 | 상태 |
| :--- | :--- |
| iOS Simulator | ✅ 정상 실행 (Hot Restart) |
| Android Emulator | ✅ 정상 실행 (Hot Restart) |
| 사진 크롭 UI | ✅ Flutter Custom UI 적용 |

---

## 추가 확인 필요 (선택사항)

dependency_overrides에 아직 남아있는 항목:
- `path_provider_foundation: 2.4.0` (최신 2.6.0)
- `objective_c: 1.0.0` (최신 9.2.4)

> [!TIP]
> 이 override들은 다른 패키지와의 호환성 이슈로 유지 중입니다. 향후 의존성이 안정화되면 제거 가능합니다.
