import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 백업 및 복원 서비스
/// Zip 파일로 데이터(JSON) + 사진을 묶어 내보내기/가져오기
class BackupService {
  static const String _eventsKey = 'CACHED_EVENTS';
  static const String _photosFolder = 'event_photos';
  static const String _dataFileName = 'data.json';
  static const String _lastBackupKey = 'LAST_BACKUP_DATE';

  /// 백업 파일 생성 및 공유
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> exportBackup() async {
    if (kIsWeb) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey) ?? '[]';

      // Zip 아카이브 생성
      final archive = Archive();

      // 1. 이벤트 데이터 추가
      final dataBytes = utf8.encode(eventsJson);
      archive.addFile(ArchiveFile(
        _dataFileName,
        dataBytes.length,
        dataBytes,
      ));

      // 2. 사진 파일 추가
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(docsDir.path, _photosFolder));

      if (await photosDir.exists()) {
        final photoFiles = photosDir.listSync().whereType<File>();
        for (final file in photoFiles) {
          final fileName = p.basename(file.path);
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(
            '$_photosFolder/$fileName',
            bytes.length,
            bytes,
          ));
        }
      }

      // 3. Zip 압축
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        debugPrint('BackupService: Zip encoding failed');
        return false;
      }

      // 4. 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName = 'days_plus_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.zip';
      final tempFile = File(p.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(zipData);

      // 5. 공유 (파일 저장/드라이브 업로드)
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'Days+ Backup',
      );

      // 6. 마지막 백업 날짜 저장
      await prefs.setString(_lastBackupKey, now.toIso8601String());

      debugPrint('BackupService: Export success - $fileName');
      return true;
    } catch (e, st) {
      debugPrint('BackupService: Export error - $e\n$st');
      return false;
    }
  }

  /// 백업 파일에서 데이터 복원
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> importBackup() async {
    if (kIsWeb) return false;

    try {
      // 1. 파일 선택
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('BackupService: No file selected');
        return false;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        debugPrint('BackupService: File path is null');
        return false;
      }

      // 2. Zip 파일 읽기
      final zipFile = File(filePath);
      final zipBytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      // 3. data.json 찾기 및 검증
      final dataFile = archive.findFile(_dataFileName);
      if (dataFile == null) {
        debugPrint('BackupService: Invalid backup - no data.json');
        return false;
      }

      // 4. 기존 사진 폴더 비우기
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(docsDir.path, _photosFolder));
      if (await photosDir.exists()) {
        await photosDir.delete(recursive: true);
      }
      await photosDir.create(recursive: true);

      // 5. 파일 복원
      String? eventsJson;
      for (final file in archive) {
        if (file.isFile) {
          if (file.name == _dataFileName) {
            // 이벤트 데이터
            eventsJson = utf8.decode(file.content as List<int>);
          } else if (file.name.startsWith('$_photosFolder/')) {
            // 사진 파일
            final fileName = p.basename(file.name);
            final destFile = File(p.join(photosDir.path, fileName));
            await destFile.writeAsBytes(file.content as List<int>);
          }
        }
      }

      // 6. SharedPreferences 업데이트
      if (eventsJson != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_eventsKey, eventsJson);
        debugPrint('BackupService: Import success - events restored');
        return true;
      }

      return false;
    } catch (e, st) {
      debugPrint('BackupService: Import error - $e\n$st');
      return false;
    }
  }

  /// 마지막 백업 날짜 가져오기
  Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_lastBackupKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}
