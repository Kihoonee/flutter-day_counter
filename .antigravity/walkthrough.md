# Walkthrough: 이벤트 사진 저장 방식 개선

## 완료된 작업

### 1. 문제 분석
- **원인**: iOS에서 앱 재설치 또는 업데이트 시 앱 컨테이너의 UUID가 변경되어 절대 경로가 무효화됨.
- **결과**: 저장된 사진이 불러와지지 않음.

### 2. 구현된 변경 사항

#### [platform_utils_io.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/utils/platform_utils_io.dart)
- **`resolvePath`** (신규): 상대 경로를 현재 시점의 절대 경로로 변환.
- **`getImageProviderAsync`** (신규): 상대/절대 경로를 받아 동적으로 `ImageProvider` 반환.
- **`fileExists`** 수정: 상대 경로도 처리 가능하도록 개선.

render_diffs(file:///Users/kihoonee/flutter/day_counter/lib/core/utils/platform_utils_io.dart)

#### [image_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/image_service.dart)
- **크기 최적화**: 이미지 최대 크기를 1200px → **800px**로 축소.
- **품질 최적화**: 이미지 품질을 85% → **80%**로 조정.
- **상대 경로 반환**: `_saveToAppDirectory`가 `event_photos/uuid.jpg` 형태의 상대 경로 반환.
- **삭제 로직 개선**: `deleteImage`가 상대 경로를 처리하도록 수정.

render_diffs(file:///Users/kihoonee/flutter/day_counter/lib/core/services/image_service.dart)

#### UI 컴포넌트
- [poster_card.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/poster_card.dart): `_buildPhoto`에서 `getImageProviderAsync` 사용.
- [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart): 사진 미리보기에서 `getImageProviderAsync` 사용.

### 3. 검증
- iOS 시뮬레이터(iPhone 17 Pro)에서 빌드 및 실행 성공.
- 분석 결과 블로킹 에러 없음 (미사용 변수, deprecated API 등 info-level 경고만 존재).

## 수동 검증 필요 사항
1.  새 이벤트 생성 시 사진을 추가하고 저장.
2.  앱을 완전히 종료 후 다시 실행하여 사진 유지 확인.
3.  이벤트 삭제 시 사진 파일도 정상 삭제되는지 확인.
