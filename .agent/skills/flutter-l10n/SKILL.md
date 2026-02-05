---
name: flutter-l10n
description: Flutter 프로젝트에서 새로운 UI 문자열(String)을 추가하거나 수정할 때 반드시 참조해야 하는 스킬입니다. 소스 코드 내 하드코딩을 방지하고 다국어 지원(l10n) 표준 절차(ARB 파일 업데이트 및 코드 적용)를 준수하도록 강제합니다.
---

# Flutter 다국어 지원 (Localization) 가이드

이 스킬은 프로젝트 내의 모든 사용자 노출 문자열을 다국어 지원 파일(`lib/l10n/*.arb`)로 관리하도록 규정합니다.

## 🚀 기본 원칙
1.  **하드코딩 금지**: UI 위젯 내부나 비즈니스 로직에 한국어/영어 문자열을 직접 입력하지 마세요.
2.  **ARB 우선**: 모든 문자열은 반드시 `lib/l10n/app_ko.arb`와 `lib/l10n/app_en.arb`에 먼저 정의되어야 합니다.
3.  **L10n 코드 사용**: 코드에서는 `AppLocalizations.of(context)!.keyName` 형식을 사용하세요.

## 🛠 문자열 추가 워크플로우

### 1단계: ARB 파일 업데이트
`lib/l10n/` 디렉토리의 모든 ARB 파일에 새로운 키를 추가하세요.

**예: `app_ko.arb`**
```json
{
  "newFeatureTitle": "새로운 기능",
  "welcomeMessage": "안녕하세요, {name}님!"
}
```

**예: `app_en.arb`**
```json
{
  "newFeatureTitle": "New Feature",
  "welcomeMessage": "Hello, {name}!"
}
```

### 2단계: 파라미터 정의 (필요 시)
변수가 포함된 문자열은 `@` 접두사가 붙은 메타데이터를 사용하여 플레이스홀더를 정의해야 합니다.

```json
"welcomeMessage": "안녕하세요, {name}님!",
"@welcomeMessage": {
  "description": "사용자 환영 인사",
  "placeholders": {
    "name": { "type": "String" }
  }
}
```

### 3단계: UI 코드 연동
위젯에서 `AppLocalizations`를 참조하여 문자열을 가져옵니다.

```dart
final l10n = AppLocalizations.of(context)!;

Text(l10n.newFeatureTitle);
Text(l10n.welcomeMessage("홍길동"));
```

## ⚠️ 주의사항
- **일관성**: `app_ko.arb`에 추가한 키는 **반드시** `app_en.arb`에도 동일하게 추가해야 합니다.
- **빌드**: ARB 파일을 수정한 후 코드가 인식되지 않는다면 다음 명령어를 실행하여 l10n 코드를 재생성하세요:
  ```bash
  flutter gen-l10n
  ```
- **네이밍 규칙**: 키 이름은 `camelCase`를 사용하며, 용도를 명확히 알 수 있도록 작성하세요 (예: `loginButtonLabel`, `emptyStateMessage`).
