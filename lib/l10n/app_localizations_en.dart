// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Days+';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get add => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get appearanceSettings => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get auto => 'Auto';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get globalNotificationSetting => 'Global Notification';

  @override
  String get globalNotificationSubtitle =>
      'Mutes all notifications when turned off.';

  @override
  String get settingsSaved => 'Settings saved successfully.';

  @override
  String get saveSuccess => 'Saved successfully.';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get addAnniversary => 'Add Anniversary';

  @override
  String get emptyEventsTitle => 'No D-Days registered yet';

  @override
  String get emptyEventsSubtitle => 'Start by adding your first D-Day!';

  @override
  String get createNewEvent => 'Create New Event';

  @override
  String get dDay => 'D-Day';

  @override
  String dMinus(int days) {
    return 'D-$days';
  }

  @override
  String dPlus(int days) {
    return 'D+$days';
  }

  @override
  String get newEvent => 'New Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get eventTitleLabel => 'What day is it?';

  @override
  String get eventTitleHint => 'Enter event title';

  @override
  String get eventDefaultTitle => 'Event';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get icon => 'Icon';

  @override
  String get theme => 'Theme';

  @override
  String get targetDate => 'Target Date';

  @override
  String get includeTodayLabel => 'Include Today (Day 1)';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notifyDDayLabel => 'D-Day Notification';

  @override
  String get notifyDMinus1Label => 'D-1 Notification';

  @override
  String get notifyAnniversaryLabel => 'Anniversary Notification (+100 days)';

  @override
  String get deleteConfirmTitle => 'Delete this event?';

  @override
  String get deleteConfirmContent => 'This action cannot be undone.';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String saveFailedWithParam(String error) {
    return 'Save failed: $error';
  }

  @override
  String get shareFailed => 'Failed to share.';

  @override
  String get eventNotFound => 'Event not found.';

  @override
  String get todoTab => 'To-Do';

  @override
  String get diaryTab => 'Memo';

  @override
  String get editTab => 'Edit';

  @override
  String get todoHint => 'Enter a task';

  @override
  String get todoEmptyTitle => 'Add a task to get started';

  @override
  String get diaryEmptyTitle => 'No memories recorded yet';

  @override
  String get diaryEmptySubtitle => 'Share your first story';

  @override
  String get diaryDialogTitleNew => 'Record Today';

  @override
  String get diaryDialogTitleEdit => 'Edit Record';

  @override
  String get diaryHint => 'Leave a precious memory...';

  @override
  String get deleteDiaryConfirm => 'Delete this diary entry?';

  @override
  String get limitSheetTitle => 'Free creation limit exceeded (3/3)';

  @override
  String get limitSheetBody =>
      'Would you like to watch a short ad\nto add one more anniversary?';

  @override
  String get watchAdButton => 'Watch ad and add';

  @override
  String get adLoadFailed => 'Could not load ad. Please try again later.';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get licenses => 'Open Source Licenses';

  @override
  String get contactEmailSubject => '[Days+] Feedback/Support';

  @override
  String get transitionGuideTitle => 'The day has come ✨';

  @override
  String transitionGuideBody(String title) {
    return 'Today is \'$title\'\n\nYour to-dos have become memories.\nFrom now on, record your precious\nmemories in the \'Memo\' tab 💭';
  }

  @override
  String get transitionGuideButton => 'Start recording memories';
}
