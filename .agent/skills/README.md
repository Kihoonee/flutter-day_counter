# Scripts

이 폴더에는 반복적인 작업을 자동화하는 Dart 스크립트와 쉘 스크립트가 위치합니다.

## 사용법

Dart 스크립트 실행:
```bash
dart run scripts/example_script.dart
```

## 스크립트 작성 가이드

- 모든 스크립트는 **결정론적(Deterministic)**이어야 합니다.
- 같은 입력에 대해 항상 같은 결과를 반환해야 합니다.
- 에러 처리를 명확히 하고, 실패 시 적절한 종료 코드를 반환합니다.
- 주석을 충분히 달아 다른 개발자(또는 AI)가 이해할 수 있게 합니다.

## 예시 스크립트
- `generate_assets.dart` - 에셋 파일 자동 생성
- `clean_build.sh` - 빌드 캐시 정리
- `update_version.dart` - 앱 버전 자동 업데이트
