---
name: multi-device-run
description: iOS 시뮬레이터(iPhone 17 Pro)와 안드로이드 에뮬레이터(emulator-5554)에서 Flutter 앱을 동시에 실행하고 테스트할 때 사용합니다. "시뮬레이터랑 에뮬레이터 둘 다 띄워줘", "멀티 디바이스에서 실행해줘" 등의 요청에 대응합니다.
---

# Multi Device Run

## 개요

이 스킬은 개발자가 iOS와 Android 환경에서 UI 및 기능의 일관성을 동시에 확인할 수 있도록 여러 디바이스에서 앱을 병렬로 실행하는 기능을 제공합니다.

## 사용 방법

### 1. 스크립트 실행
`.agent/skills/multi-device-run/scripts/run_multi.sh` 스크립트를 실행하여 iOS 시뮬레이터와 안드로이드 에뮬레이터에서 앱을 동시에 구동합니다.

```bash
sh .agent/skills/multi-device-run/scripts/run_multi.sh
```

### 2. 개별 실행 (참고)
특정 디바이스에만 수동으로 실행하고 싶을 경우 다음 명령어를 참고하세요.

- **iPhone 17 Pro**: `flutter run -d 0D590785-B970-43D0-BE1F-368862470165`
- **Android Emulator**: `flutter run -d emulator-5554`

## 리소스

### scripts/
- `run_multi.sh`: 두 디바이스에서 앱을 병렬로 실행하는 메인 쉘 스크립트입니다.

## 주의 사항
- 실행 전에 시뮬레이터와 에뮬레이터가 각각 켜져 있거나 실행 가능한 상태여야 합니다.
- 병렬 실행 시 시스템 자원을 많이 소모할 수 있으므로 빌드 시간을 고려해야 합니다.
