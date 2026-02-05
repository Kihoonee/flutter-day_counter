# Task: Days+ 출시 고도화 및 핵심 기능(공유) 리부트

안정적인 버전(a1522b5)으로 롤백 후, 신뢰할 수 있는 기반 위에서 공유 기능과 출시 준비 작업을 다시 수행합니다.

## Status: Planning (Fresh Start)

## Progress
### 📈 분석 및 계획
- [x] 현재 코드베이스(a1522b5) 상태 점검 및 빌드 확인
  - [x] Riverpod 3.x 호환성 수정 (StateNotifier -> Notifier)
  - [x] AdMob 7.x 콜백 서명 수정
  - [x] AsyncValue API 수정 (valueOrNull -> value)
- [/] 보상형 광고 로직 확인 및 검증

### 🛠️ 기능 구현 (Execution)
- [x] **소셜 공유 기능**: 포스터 카드 캡처 및 공유 로직 구현 완료
  - [x] screenshot, share_plus 패키지 추가
  - [x] ShareService 클래스 구현
  - [x] 이벤트 상세 페이지에 공유 버튼 추가
  - [x] 다국어 지원 (한국어/영어)
  - [x] **[버그 수정]** 히어로 애니메이션 이미지 깜빡임 해결 (동기 로딩 적용)
- [ ] **Apple 심사 대응 UI**: 설정 페이지 보강 (버전, 문의, 라이선스)
- [ ] **감성 UX**: 할일-메모 전환 안내 팝업 구현

### ✅ 검증 (Verification)
- [x] iOS/Android 멀티 디바이스 기능 검증 (공유 기능)
- [/] 레이아웃 안정성 및 렌더링 에러 전수 조사 (진행 중)
