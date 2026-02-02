# Task: Per-Event Granular Notifications

Refactor granular notification settings to be managed per-event instead of globally. Settings page will only retain the master global switch.

## Status: Completed

## Progress
- [x] Refine `EventEditPage` Toggle Logic
    - [x] Make granular toggles always visible (remove conditional visibility)
    - [x] Parent -> Child: Turning off parent turns off all children
    - [x] Child -> Parent: Turning on any child turns on the parent
- [x] Refine Global Notification Rescheduling
    - [x] Ensure `SettingsPage` correctly triggers rescheduling when Global ON
    - [x] Verify `NotificationService` respects per-event settings during mass reschedule
- [x] Verification
    - [x] Test Parent-Child UI interaction in Edit Page
    - [x] Test Global Off -> On behavior and check scheduled notifications
