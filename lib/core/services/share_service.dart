import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// 포스터 카드를 이미지로 캡처하고 공유하는 서비스
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  final ScreenshotController screenshotController = ScreenshotController();

  /// 위젯을 이미지로 캡처하고 공유
  Future<void> shareWidget({
    required Widget widget,
    required String fileName,
    String? text,
  }) async {
    try {
      // 위젯을 이미지로 캡처
      final Uint8List? imageBytes = await screenshotController.captureFromWidget(
        widget,
        pixelRatio: 3.0, // 고해상도
        context: null,
      );

      if (imageBytes == null) {
        debugPrint('ShareService: Failed to capture widget');
        return;
      }

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/$fileName.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // 공유
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: text,
      );

      debugPrint('ShareService: Successfully shared image: $imagePath');
    } catch (e) {
      debugPrint('ShareService: Error sharing widget: $e');
      rethrow;
    }
  }

  /// 현재 화면을 캡처하고 공유 (ScreenshotController로 감싼 위젯용)
  Future<void> captureAndShare({
    required String fileName,
    String? text,
  }) async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        debugPrint('ShareService: Failed to capture screen');
        return;
      }

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/$fileName.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // 공유
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: text,
      );

      debugPrint('ShareService: Successfully shared screenshot: $imagePath');
    } catch (e) {
      debugPrint('ShareService: Error capturing and sharing: $e');
      rethrow;
    }
  }
}
