# Task: Remove 'Include Today' from Settings

The user wants to remove the "Include Today" default setting configuration from the Settings page. This means the app will rely on a hardcoded default (likely `true`) for new events, simplifying the settings menu.

## Status: Completed

## Progress
- [x] Remove 'Include Today' from `SettingsPage`
    - [x] Remove UI toggle
    - [x] Remove state and persistence logic
- [x] Refine Global Notifications in `SettingsPage`
    - [x] Add granular toggles (D-Day, D-1, 100일 단위)
    - [x] Update state and persistence logic for each type
- [x] Update `NotificationService`
    - [x] Respect granular global settings in `scheduleEvent`
- [x] Update `EventEditPage`
    - [x] Remove dependency on `default_includeToday` preference
    - [x] Set default value to `true`
- [x] Verification
    - [x] Verify Settings page UI
    - [x] Verify granular notification scheduling
    - [x] Verify new event creation defaults
