import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'Days+'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get done;

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @appearanceSettings.
  ///
  /// In ko, this message translates to:
  /// **'화면 설정'**
  String get appearanceSettings;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @korean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In ko, this message translates to:
  /// **'영어'**
  String get english;

  /// No description provided for @auto.
  ///
  /// In ko, this message translates to:
  /// **'자동'**
  String get auto;

  /// No description provided for @themeMode.
  ///
  /// In ko, this message translates to:
  /// **'테마 모드'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get system;

  /// No description provided for @light.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get dark;

  /// No description provided for @notificationSettings.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notificationSettings;

  /// No description provided for @globalNotificationSetting.
  ///
  /// In ko, this message translates to:
  /// **'전역 알림 설정'**
  String get globalNotificationSetting;

  /// No description provided for @globalNotificationSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'꺼두면 모든 알림이 울리지 않습니다.'**
  String get globalNotificationSubtitle;

  /// No description provided for @settingsSaved.
  ///
  /// In ko, this message translates to:
  /// **'설정이 저장되었습니다.'**
  String get settingsSaved;

  /// No description provided for @saveSuccess.
  ///
  /// In ko, this message translates to:
  /// **'저장되었습니다.'**
  String get saveSuccess;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'에러: {message}'**
  String error(String message);

  /// No description provided for @addAnniversary.
  ///
  /// In ko, this message translates to:
  /// **'기념일 추가하기'**
  String get addAnniversary;

  /// No description provided for @emptyEventsTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 등록된 D-Day가 없어요'**
  String get emptyEventsTitle;

  /// No description provided for @emptyEventsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 D-Day를 추가해보세요!'**
  String get emptyEventsSubtitle;

  /// No description provided for @createNewEvent.
  ///
  /// In ko, this message translates to:
  /// **'새 이벤트 만들기'**
  String get createNewEvent;

  /// No description provided for @dDay.
  ///
  /// In ko, this message translates to:
  /// **'D-Day'**
  String get dDay;

  /// No description provided for @dMinus.
  ///
  /// In ko, this message translates to:
  /// **'D-{days}'**
  String dMinus(int days);

  /// No description provided for @dPlus.
  ///
  /// In ko, this message translates to:
  /// **'D+{days}'**
  String dPlus(int days);

  /// No description provided for @newEvent.
  ///
  /// In ko, this message translates to:
  /// **'새 이벤트'**
  String get newEvent;

  /// No description provided for @editEvent.
  ///
  /// In ko, this message translates to:
  /// **'이벤트 수정'**
  String get editEvent;

  /// No description provided for @eventTitleLabel.
  ///
  /// In ko, this message translates to:
  /// **'어떤 날인가요?'**
  String get eventTitleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'이벤트 제목을 입력하세요'**
  String get eventTitleHint;

  /// No description provided for @eventDefaultTitle.
  ///
  /// In ko, this message translates to:
  /// **'이벤트'**
  String get eventDefaultTitle;

  /// No description provided for @changePhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 변경'**
  String get changePhoto;

  /// No description provided for @addPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 추가'**
  String get addPhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 삭제'**
  String get deletePhoto;

  /// No description provided for @icon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘'**
  String get icon;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @targetDate.
  ///
  /// In ko, this message translates to:
  /// **'목표일'**
  String get targetDate;

  /// No description provided for @includeTodayLabel.
  ///
  /// In ko, this message translates to:
  /// **'당일 포함 (1일차 시작)'**
  String get includeTodayLabel;

  /// No description provided for @enableNotifications.
  ///
  /// In ko, this message translates to:
  /// **'알림 켜기'**
  String get enableNotifications;

  /// No description provided for @notifyDDayLabel.
  ///
  /// In ko, this message translates to:
  /// **'D-Day 알림'**
  String get notifyDDayLabel;

  /// No description provided for @notifyDMinus1Label.
  ///
  /// In ko, this message translates to:
  /// **'D-1 알림'**
  String get notifyDMinus1Label;

  /// No description provided for @notifyAnniversaryLabel.
  ///
  /// In ko, this message translates to:
  /// **'기념일 알림 (+100일 단위)'**
  String get notifyAnniversaryLabel;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'삭제할까요?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'이 이벤트를 삭제합니다.'**
  String get deleteConfirmContent;

  /// No description provided for @deleteEvent.
  ///
  /// In ko, this message translates to:
  /// **'이벤트 삭제'**
  String get deleteEvent;

  /// No description provided for @saveChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경사항 저장'**
  String get saveChanges;

  /// No description provided for @saveFailedWithParam.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String saveFailedWithParam(String error);

  /// No description provided for @shareFailed.
  ///
  /// In ko, this message translates to:
  /// **'공유에 실패했습니다.'**
  String get shareFailed;

  /// No description provided for @eventNotFound.
  ///
  /// In ko, this message translates to:
  /// **'이벤트를 찾을 수 없습니다.'**
  String get eventNotFound;

  /// No description provided for @todoTab.
  ///
  /// In ko, this message translates to:
  /// **'할 일'**
  String get todoTab;

  /// No description provided for @diaryTab.
  ///
  /// In ko, this message translates to:
  /// **'한줄메모'**
  String get diaryTab;

  /// No description provided for @editTab.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get editTab;

  /// No description provided for @todoHint.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 입력하세요'**
  String get todoHint;

  /// No description provided for @todoEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 추가해보세요'**
  String get todoEmptyTitle;

  /// No description provided for @diaryEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록된 추억이 없어요'**
  String get diaryEmptyTitle;

  /// No description provided for @diaryEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 이야기를 남겨보세요'**
  String get diaryEmptySubtitle;

  /// No description provided for @diaryDialogTitleNew.
  ///
  /// In ko, this message translates to:
  /// **'오늘을 기록해요'**
  String get diaryDialogTitleNew;

  /// No description provided for @diaryDialogTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'기록 수정'**
  String get diaryDialogTitleEdit;

  /// No description provided for @diaryHint.
  ///
  /// In ko, this message translates to:
  /// **'소중한 기억을 남겨주세요...'**
  String get diaryHint;

  /// No description provided for @deleteDiaryConfirm.
  ///
  /// In ko, this message translates to:
  /// **'일기를 삭제할까요?'**
  String get deleteDiaryConfirm;

  /// No description provided for @limitSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'무료 생성 한도 초과 (3/3)'**
  String get limitSheetTitle;

  /// No description provided for @limitSheetBody.
  ///
  /// In ko, this message translates to:
  /// **'짧은 광고를 시청하고\n기념일을 하나 더 추가하시겠어요?'**
  String get limitSheetBody;

  /// No description provided for @watchAdButton.
  ///
  /// In ko, this message translates to:
  /// **'광고 보고 추가'**
  String get watchAdButton;

  /// No description provided for @adLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'**
  String get adLoadFailed;

  /// No description provided for @appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @contactUs.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get contactUs;

  /// No description provided for @licenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get licenses;

  /// No description provided for @contactEmailSubject.
  ///
  /// In ko, this message translates to:
  /// **'[Days+] 문의사항'**
  String get contactEmailSubject;

  /// No description provided for @transitionGuideTitle.
  ///
  /// In ko, this message translates to:
  /// **'그날이 왔어요 ✨'**
  String get transitionGuideTitle;

  /// No description provided for @transitionGuideBody.
  ///
  /// In ko, this message translates to:
  /// **'오늘은 \'{title}\'\n\n할일은 이제 추억이 되었어요.\n이제부터는 \'한줄메모\' 탭에서\n소중한 기억을 기록해보세요 💭'**
  String transitionGuideBody(String title);

  /// No description provided for @transitionGuideButton.
  ///
  /// In ko, this message translates to:
  /// **'추억 기록하러 가기'**
  String get transitionGuideButton;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터 관리'**
  String get backupRestoreTitle;

  /// No description provided for @backupTitle.
  ///
  /// In ko, this message translates to:
  /// **'백업하기'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터와 추억을 파일로 저장합니다.'**
  String get backupSubtitle;

  /// No description provided for @backupSuccess.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일이 생성되었습니다.'**
  String get backupSuccess;

  /// No description provided for @backupFail.
  ///
  /// In ko, this message translates to:
  /// **'백업에 실패했습니다.'**
  String get backupFail;

  /// No description provided for @restoreTitle.
  ///
  /// In ko, this message translates to:
  /// **'복원하기'**
  String get restoreTitle;

  /// No description provided for @restoreSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일에서 데이터를 복구합니다.'**
  String get restoreSubtitle;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터 덮어쓰기 경고'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'현재 모든 데이터가 삭제되고 백업 데이터로 교체됩니다. 계속하시겠습니까?'**
  String get restoreConfirmContent;

  /// No description provided for @restoreSuccess.
  ///
  /// In ko, this message translates to:
  /// **'데이터가 복원되었습니다. 앱을 재시작해주세요.'**
  String get restoreSuccess;

  /// No description provided for @restoreFail.
  ///
  /// In ko, this message translates to:
  /// **'복원에 실패했습니다.'**
  String get restoreFail;

  /// No description provided for @lastBackupFormat.
  ///
  /// In ko, this message translates to:
  /// **'마지막 백업: {date}'**
  String lastBackupFormat(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
