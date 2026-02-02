# Task: Per-Event Granular Notifications

Refactor granular notification settings to be managed per-event instead of globally. Settings page will only retain the master global switch.

## Status: Completed

## Progress
- [x] Update `Event` Model
    - [x] Add `notifyDDay`, `notifyDMinus1`, `notifyAnniv` fields
- [x] Update `EventEditPage`
    - [x] Add granular notification toggles to the UI
    - [x] Handle state and persistence for these new fields
- [x] Simplify `SettingsPage`
    - [x] Remove granular global toggles
    - [x] Retain only the master global switch
- [x] Update `NotificationService`
    - [x] Check both master global switch AND per-event granular settings
- [x] Verification
    - [x] Verify per-event notification scheduling logic
    - [x] Verify UI flow in both Settings and Edit pages
