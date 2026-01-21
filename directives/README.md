# Directives

이 폴더에는 AI 에이전트가 참고해야 할 SOP(Standard Operating Procedure) 문서들이 위치합니다.

## 파일 작성 가이드

각 Directive 파일은 다음 형식을 따릅니다:

```markdown
# [작업 이름]

## 목표
- 이 작업이 달성해야 할 것

## 입력
- 필요한 입력 데이터 또는 조건

## 실행 도구
- 사용할 스크립트 또는 명령어 (scripts/ 폴더 참조)

## 출력
- 예상되는 결과물

## 주의사항
- 에러 처리, API 제한, 타이밍 등
```

## 예시 파일
- `add_feature.md` - 새 기능 추가 시 따라야 할 절차
- `setup_firebase.md` - Firebase 설정 방법
- `deploy_app.md` - 앱 배포 절차
