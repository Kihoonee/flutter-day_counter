# 출력 패턴

스킬이 일관되고 고품질의 출력을 생성해야 할 때 이 패턴을 사용하세요.

## 템플릿 패턴

출력 형식을 위한 템플릿을 제공합니다. 필요에 따라 엄격함 수준을 맞추세요.

**엄격한 요구사항(API 응답 또는 데이터 형식 등)의 경우:**

```markdown
## 보고서 구조

항상 이 정확한 템플릿 구조를 사용하세요:

# [분석 제목]

## 요약
[주요 결과에 대한 한 단락 개요]

## 주요 발견사항
- 지원 데이터가 있는 발견사항 1
- 지원 데이터가 있는 발견사항 2
- 지원 데이터가 있는 발견사항 3

## 권장사항
1. 구체적이고 실행 가능한 권장사항
2. 구체적이고 실행 가능한 권장사항
```

**유연한 가이드(적응이 유용할 때)의 경우:**

```markdown
## 보고서 구조

다음은 합리적인 기본 형식이지만, 최선의 판단을 사용하세요:

# [분석 제목]

## 요약
[개요]

## 주요 발견사항
[발견한 내용에 따라 섹션 조정]

## 권장사항
[특정 맥락에 맞게 조정]

특정 분석 유형에 맞게 필요에 따라 섹션을 조정하세요.
```

## 예제 패턴

출력 품질이 예제를 보는 것에 달려 있는 스킬의 경우 입력/출력 쌍을 제공합니다:

```markdown
## 커밋 메시지 형식

다음 예제를 따라 커밋 메시지를 생성하세요:

**예제 1:**
입력: JWT 토큰을 사용한 사용자 인증 추가
출력:
```
feat(auth): JWT 기반 인증 구현

로그인 엔드포인트 및 토큰 검증 미들웨어 추가
```

**예제 2:**
입력: 보고서에서 날짜가 잘못 표시되는 버그 수정
출력:
```
fix(reports): 시간대 변환에서 날짜 형식 수정

보고서 생성 전체에서 UTC 타임스탬프를 일관되게 사용
```

이 스타일을 따르세요: type(scope): 간단한 설명, 그 다음 상세 설명.
```

예제는 Claude가 설명만으로는 알 수 없는 원하는 스타일과 세부 수준을 이해하는 데 도움이 됩니다.

---

## Flutter 전용 출력 패턴

### Feature 폴더 구조 템플릿

새 기능을 생성할 때 항상 이 구조를 따르세요:

```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   └── [feature]_remote_data_source.dart
│   ├── models/
│   │   └── [feature]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [feature]_entity.dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── usecases/
│       └── get_[feature]_usecase.dart
└── presentation/
    ├── providers/
    │   └── [feature]_provider.dart
    ├── screens/
    │   └── [feature]_screen.dart
    └── widgets/
        └── [feature]_widget.dart
```

### Riverpod Provider 출력 패턴

**StateNotifier 패턴 (복잡한 상태):**

```dart
@riverpod
class FeatureName extends _$FeatureName {
  @override
  FeatureState build() {
    return const FeatureState.initial();
  }

  Future<void> loadData() async {
    state = const FeatureState.loading();
    try {
      final data = await ref.read(repositoryProvider).getData();
      state = FeatureState.loaded(data);
    } catch (e) {
      state = FeatureState.error(e.toString());
    }
  }
}
```

**AsyncNotifier 패턴 (비동기 데이터):**

```dart
@riverpod
class FeatureName extends _$FeatureName {
  @override
  Future<List<FeatureEntity>> build() async {
    return await ref.read(repositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(repositoryProvider).getAll()
    );
  }
}
```

### Freezed 모델 출력 패턴

**Entity (Domain Layer):**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_entity.freezed.dart';

@freezed
class FeatureEntity with _$FeatureEntity {
  const factory FeatureEntity({
    required String id,
    required String name,
    @Default(false) bool isActive,
  }) = _FeatureEntity;
}
```

**Model (Data Layer, JSON 직렬화 포함):**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_model.freezed.dart';
part '[feature]_model.g.dart';

@freezed
class FeatureModel with _$FeatureModel {
  const factory FeatureModel({
    required String id,
    required String name,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
  }) = _FeatureModel;

  factory FeatureModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureModelFromJson(json);
}
```

### Screen Widget 출력 패턴

**ConsumerWidget 사용:**

```dart
class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature')),
      body: state.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(data[index].name),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

이 패턴들은 일관된 코드 스타일과 Clean Architecture 원칙을 따르면서 빠르게 기능을 구현하는 데 도움이 됩니다.
