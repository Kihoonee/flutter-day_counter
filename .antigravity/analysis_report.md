# Days+ Project Technical Report (2026.02)

이 문서는 **Days+** 앱의 현재 구현 상태와 기술 사양을 요약한 보고서입니다. 초기 경쟁사 분석 단계를 지나 현재는 핵심 기능 대부분이 구현되어 릴리즈 안정화 단계에 있습니다.

---

## 🚀 구현된 핵심 기능 (Core Features)

| 기능 | 상태 | 상세 내용 |
| :--- | :---: | :--- |
| **디데이 관리** | ✅ 완료 | 이벤트 생성, 수정, 삭제 및 파스텔 테마(Wave 패턴) 적용 |
| **홈 화면 위젯** | ✅ 완료 | iOS/Android 위젯 지원. 다중 위젯 인스턴스 데이터 격리 및 실시간 업데이트 |
| **할 일 (To-Do)** | ✅ 완료 | 이벤트별 체크리스트 관리 기능 |
| **다이어리 (기록)** | ✅ 완료 | 이벤트와 연관된 날짜별 메모 및 추억 기록 |
| **알림 (Notification)** | ✅ 완료 | 로컬 푸시 알림 (당일, D-1, 기념일 등) 및 이벤트별 개별 설정 |
| **다국어 지원** | ✅ 완료 | 한국어, 영어 지원 및 설정 화면에서 수동/자동 전환 가능 |
| **광고 (Ads)** | ✅ 완료 | Google AdMob 통합 (배너, 전면, 앱 오픈 광고) |
| **이미지 관리** | ✅ 완료 | 사진 선택 및 크롭 기능을 통한 커스텀 배경 설정 (상대 경로 저장 방식 적용) |

---

## 🛠 기술 스택 (Technical Stack)

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Database**: Sembast (NoSQL)
- **Architecture**: 3-Layer (Directives - Orchestration - Skills)
- **Native Interaction**:
  - Android: Kotlin (AppWidget, SharedPreferences)
  - iOS: Swift (WidgetKit, AppGroup)
- **Cloud Services**: Firebase (Core, Messaging, Analytics)

---

## 🔒 복구 및 핸드오버 (Context Management)

현재 프로젝트는 **3-Layer 아키텍처** 가이드라인에 따라 운영됩니다.
- **`.antigravity/`**: 작업 맥락을 유지하기 위한 작업 파일(`task.md`, `implementation_plan.md` 등) 보관.
- **`.agent/skills/`**: 반복되는 작업을 위한 결정론적 스크립트 및 지침 보관.
  - `admob-integration`: 광고 설정 가이드
  - `firebase-setup`: Firebase 연동 자동화
  - `release-build`: 릴리즈 빌드 및 설치 가이드
  - `git-commit`: 컨벤션 기반 커밋 자동화

---

## 💡 향후 개선 계획 (Roadmap)

1.  **클라우드 동기화**: 로그인 기능을 통한 기기간 데이터 동기화.
2.  **공유하기 확장**: 감성 디데이 카드를 이미지 파일로 내보내거나 SNS에 직접 공유하는 기능.
3.  **애니메이션 강화**: 메인 화면 및 카드 전환 시 더 부드러운 마이크로 인터랙션 추가.

---
최종 갱신일: 2026.02.04
