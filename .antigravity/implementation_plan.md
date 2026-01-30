# 사진 추가 항목 위치 변경 계획

'새 이벤트' 등록 화면과 '이벤트 수정' 화면에서 '사진 추가' 항목이 아래쪽에 있어 발견하기 어렵다는 피드백을 반영하여, '이벤트 제목' 바로 아래로 위치를 조정합니다.

## 제안된 변경 사항

### [Presentation Layer]

#### [MODIFY] [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart)
- `Column` 내부에 위치한 '사진 추가' 카드(`Card`) 섹션을 '이벤트 제목 입력' 카드 바로 다음으로 이동합니다.
- 이동 후 적절한 간격(`SizedBox`)을 유지합니다.

#### [MODIFY] [edit_tab.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/edit_tab.dart)
- `EditTab` 내의 '사진 추가' 카드 섹션을 '제목 입력' 카드 바로 하단으로 이동합니다.

## 검증 계획

### 수동 검증
1. **새 이벤트 화면**: 제목 입력 후 바로 아래에 사진 추가 항목이 있는지 확인.
2. **이벤트 수정 화면**: 상세 페이지의 '수정' 탭에서 사진 추가 항목의 위치가 제목 아래로 이동했는지 확인.
3. **기능 확인**: 위치 이동 후에도 사진 선택, 변경, 삭제 기능이 정상 작동하는지 확인.
