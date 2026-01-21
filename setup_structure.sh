# 디렉토리 생성
mkdir -p lib/core/{constants,utils,errors}
mkdir -p lib/data/database/{tables,daos}
mkdir -p lib/data/repositories
mkdir -p lib/domain/{models,repositories,usecases}
mkdir -p lib/presentation/{providers,screens,widgets}

# 기본 파일 생성
touch lib/core/constants/app_constants.dart
touch lib/core/constants/database_constants.dart
touch lib/core/utils/date_utils.dart
touch lib/core/utils/string_utils.dart
touch lib/core/errors/exceptions.dart