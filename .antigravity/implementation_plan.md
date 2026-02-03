# 이벤트 사진 저장 방식 및 용량 최적화 개선

이벤트 카드 사진의 경로 영속성 문제를 해결하고, 저장 공간 효율을 위해 사진 크기 및 품질을 최적화합니다.

## 제안된 변경 사항

### 1. 사진 경로 영속성 해결 (상대 경로 전환)
iOS의 앱 컨테이너 UUID 변경에 대응하기 위해 사진 경로를 상대 경로로 관리합니다.

#### [MODIFY] [image_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/image_service.dart)
- `_saveToAppDirectory`: 파일 저장 후 전체 절대 경로 대신 `event_photos/파일명.jpg`와 같은 **상대 경로**만 반환하도록 수정.
- `deleteImage`: 상대 경로를 전달받아 현재 앱 문서 디렉토리와 결합하여 실제 파일을 삭제하도록 수정.

#### [MODIFY] [platform_utils_io.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/utils/platform_utils_io.dart)
- `resolvePath` (신규): 저장된 상대 경로를 현재 시점의 유효한 절대 경로로 변환하는 유틸리티 추가.

### 2. 용량 최적화 (품질 및 크기 조정)
이벤트 카드의 작은 표시 영역에 맞춰 불필요한 고해상도를 지양하고 용량을 줄입니다.

#### [MODIFY] [image_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/image_service.dart)
- `pickImage`: `maxWidth`, `maxHeight`를 기존 1200에서 **800**으로 하향 조정.
- `saveToAppDirectory`: 저장 시 이미지 품질(imageQuality)을 다시 한번 체크하거나 크기를 재조정하여 파일 크기 최소화. (현재 85% 품질 유지 또는 80%로 조정 검토)

### 3. UI 컴포넌트 적용
#### [MODIFY] [poster_card.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/poster_card.dart)
- `photoPath` 사용 시 `PlatformUtilsImpl.resolvePath`를 통해 동적으로 절대 경로를 획득하여 표시하도록 수정.
- `EventEditPage`, `EventDetailPage`, `EventListPage` 등 모든 사진 노출 지점에 동일 로직 적용.

## 검증 계획

### 수동 검증
1.  **경로 정상화 확인**: 사진 저장 후 앱을 완전히 종료하고 다시 실행했을 때 사진이 잘 나오는지 확인.
2.  **파일 용량 확인**: 저장된 사진 파일의 용량이 최적화되었는지(약 100-200KB 수준 예상) 확인.
3.  **삭제 확인**: 이벤트를 삭제하거나 사진을 변경할 때 기존 파일이 정상적으로 삭제되는지 확인.

> [!NOTE]
> 사용자 요청에 따라 기존 데이터에 대한 하위 호환성(Legacy absolute path recovery) 로직은 포함하지 않습니다. 이 수정 이후 등록되는 사진부터 영구적으로 보존됩니다.
