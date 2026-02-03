// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Days+';

  @override
  String get ok => '확인';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get done => '완료';

  @override
  String get add => '추가';

  @override
  String get settings => '설정';

  @override
  String get appearanceSettings => '화면 설정';

  @override
  String get language => '언어';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';

  @override
  String get auto => '자동';

  @override
  String get themeMode => '테마 모드';

  @override
  String get system => '시스템';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get globalNotificationSetting => '전역 알림 설정';

  @override
  String get globalNotificationSubtitle => '꺼두면 모든 알림이 울리지 않습니다.';

  @override
  String get settingsSaved => '설정이 저장되었습니다.';

  @override
  String get saveSuccess => '저장되었습니다.';

  @override
  String error(String message) {
    return '에러: $message';
  }

  @override
  String get addAnniversary => '기념일 추가하기';

  @override
  String get emptyEventsTitle => '아직 등록된 D-Day가 없어요';

  @override
  String get emptyEventsSubtitle => '첫 번째 D-Day를 추가해보세요!';

  @override
  String get createNewEvent => '새 이벤트 만들기';

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
  String get newEvent => '새 이벤트';

  @override
  String get editEvent => '이벤트 수정';

  @override
  String get eventTitleLabel => '어떤 날인가요?';

  @override
  String get eventTitleHint => '이벤트 제목을 입력하세요';

  @override
  String get eventDefaultTitle => '이벤트';

  @override
  String get changePhoto => '사진 변경';

  @override
  String get addPhoto => '사진 추가';

  @override
  String get deletePhoto => '사진 삭제';

  @override
  String get icon => '아이콘';

  @override
  String get theme => '테마';

  @override
  String get targetDate => '목표일';

  @override
  String get includeTodayLabel => '당일 포함 (1일차 시작)';

  @override
  String get enableNotifications => '알림 켜기';

  @override
  String get notifyDDayLabel => 'D-Day 알림';

  @override
  String get notifyDMinus1Label => 'D-1 알림';

  @override
  String get notifyAnniversaryLabel => '기념일 알림 (+100일 단위)';

  @override
  String get deleteConfirmTitle => '삭제할까요?';

  @override
  String get deleteConfirmContent => '이 이벤트를 삭제합니다.';

  @override
  String get deleteEvent => '이벤트 삭제';

  @override
  String get saveChanges => '변경사항 저장';

  @override
  String saveFailedWithParam(String error) {
    return '저장 실패: $error';
  }

  @override
  String get eventNotFound => '이벤트를 찾을 수 없습니다.';

  @override
  String get todoTab => '할 일';

  @override
  String get diaryTab => '한줄메모';

  @override
  String get editTab => '수정';

  @override
  String get todoHint => '할 일을 입력하세요';

  @override
  String get todoEmptyTitle => '할 일을 추가해보세요';

  @override
  String get diaryEmptyTitle => '아직 기록된 추억이 없어요';

  @override
  String get diaryEmptySubtitle => '첫 번째 이야기를 남겨보세요';

  @override
  String get diaryDialogTitleNew => '오늘을 기록해요';

  @override
  String get diaryDialogTitleEdit => '기록 수정';

  @override
  String get diaryHint => '소중한 기억을 남겨주세요...';

  @override
  String get deleteDiaryConfirm => '일기를 삭제할까요?';
}
