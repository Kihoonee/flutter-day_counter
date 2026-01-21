#!/usr/bin/env bash
set -euo pipefail

# Create directories
mkdir -p \
  lib/app \
  lib/core/utils \
  lib/core/storage \
  lib/features/events/domain \
  lib/features/events/data \
  lib/features/events/presentation/pages \
  lib/features/events/presentation/widgets \
  lib/features/events/application

# Create files
touch \
  lib/main.dart \
  lib/app/app.dart \
  lib/app/router.dart \
  lib/app/theme.dart \
  lib/core/utils/date_calc.dart \
  lib/core/utils/date_format.dart \
  lib/core/storage/json_codec.dart \
  lib/features/events/domain/event.dart \
  lib/features/events/domain/event_repository.dart \
  lib/features/events/data/event_repository_prefs.dart \
  lib/features/events/presentation/pages/home_page.dart \
  lib/features/events/presentation/pages/result_page.dart \
  lib/features/events/presentation/pages/event_list_page.dart \
  lib/features/events/presentation/pages/event_edit_page.dart \
  lib/features/events/presentation/pages/settings_page.dart \
  lib/features/events/presentation/widgets/poster_card.dart \
  lib/features/events/presentation/widgets/date_field.dart \
  lib/features/events/application/event_controller.dart \
  lib/features/events/application/selected_event_controller.dart

echo "✅ Folder/file structure created."
