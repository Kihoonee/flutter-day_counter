# Days+ (데이스 플러스) 💎

**Days+**는 소중한 기념일과 일정을 현대적이고 프리미엄한 감성으로 관리할 수 있는 Flutter 기반의 디데이(D-Day) 카운터 앱입니다.

## ✨ 주요 기능

- **프리미엄 글래스모피즘 UI**: 아름다운 배경 블러 효과와 부드러운 그라데이션이 적용된 하단 바 디자인.
- **지능형 이벤트 관리**: 미래의 이벤트(할 일 중심)와 과거의 이벤트(기록 중심)를 구분하여 맥락에 맞는 기능 제공.
- **자동 메모 변환 (Smart Archive)**: 이벤트가 과거가 되는 순간, 완료되지 않은 할 일을 자동으로 한 줄 메모로 변환하여 기록 보존.
- **홈 화면 위젯**: iOS와 Android 홈 화면에서 가장 중요한 기념일을 한눈에 확인.
- **로컬 알림**: D-1, D-Day 및 주요 기념일(100일 단위 등) 푸시 알림 지원.
- **데이터 로컬 저장**: Sembast를 활용한 빠르고 안전한 오프라인 데이터 관리.

## 🛠 기술 스택

- **Framework**: Flutter (Channel Stable)
- **State Management**: [Riverpod](https://riverpod.dev/) (Generator 기반 모델 사용)
- **Local Database**: [Sembast](https://pub.dev/packages/sembast)
- **Architecture**: 3-Layer Clean Architecture & Feature-First Structure
- **UI/UX**: Custom Glassmorphism, HugeIcons, Google Fonts

## 📁 프로젝트 구조

```text
lib/
├── app/          # 앱 설정, 라우팅 (GoRouter)
├── core/         # 공용 서비스, 테마, 유틸리티 (DateCalc 등)
└── features/     # 기능별 도메인 주도 설계
    └── events/   # 기념일 관리 (application, domain, presentation)
```

## 🚀 시작하기

1. **상태 관리 코드 생성**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
2. **앱 실행**:
   ```bash
   flutter run
   ```

## 🤝 기여 및 피드백

이 프로젝트는 프리미엄한 사용자 경험과 코드의 신뢰성을 최우선으로 합니다. 버그 제보나 기능 제안은 언제든 환영합니다! 💎✨
