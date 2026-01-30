import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 이미지 처리 서비스
/// 사진 선택, 크롭, 저장, 삭제 기능 제공
class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// 갤러리에서 사진 선택 후 정사각형으로 크롭
  /// 성공 시 저장된 이미지 경로 반환, 취소/실패 시 null
  /// 크롭 취소 시 다시 갤러리 피커로 돌아감
  Future<String?> pickAndCropImage(BuildContext context) async {
    try {
      debugPrint('ImageService: pickAndCropImage start');
      
      // 크롭 취소 시 다시 갤러리로 돌아가도록 루프
      while (true) {
        // 1. 갤러리에서 이미지 선택
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );

        if (pickedFile == null) {
          debugPrint('ImageService: Picker returned null (user cancelled)');
          return null; // 갤러리에서 취소 → 완전히 종료
        }
        debugPrint('ImageService: Picked file: ${pickedFile.path}');

        // 2. 이미지 바이트 로드
        final imageBytes = await File(pickedFile.path).readAsBytes();
        debugPrint('ImageService: Loaded bytes: ${imageBytes.length}');

        // 3. 크롭 페이지로 이동
        if (!context.mounted) {
          debugPrint('ImageService: Context not mounted');
          return null;
        }
        final croppedBytes = await Navigator.push<Uint8List>(
          context,
          MaterialPageRoute(
            builder: (context) => _CropPage(imageBytes: imageBytes),
          ),
        );

        if (croppedBytes == null) {
          debugPrint('ImageService: Crop cancelled - reopening gallery');
          // 임시 파일 정리
          try {
            await File(pickedFile.path).delete();
          } catch (_) {}
          continue; // 크롭 취소 → 다시 갤러리 열기
        }
        debugPrint('ImageService: Cropped bytes received: ${croppedBytes.length}');

        // 4. 앱 디렉토리에 저장
        final savedPath = await _saveToAppDirectory(croppedBytes);
        debugPrint('ImageService: Saved to: $savedPath');

        // 5. 원본 캐시 파일 삭제
        try {
          await File(pickedFile.path).delete();
        } catch (_) {}

        return savedPath;
      }
    } catch (e) {
      debugPrint('ImageService.pickAndCropImage error: $e');
      return null;
    }
  }

  /// 크롭된 이미지를 앱 문서 디렉토리에 저장
  Future<String> _saveToAppDirectory(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(directory.path, 'event_photos'));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final destinationPath = p.join(imagesDir.path, fileName);

    await File(destinationPath).writeAsBytes(imageBytes);

    return destinationPath;
  }

  /// 이벤트 삭제 시 연결된 사진 파일 삭제
  Future<void> deleteImage(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('ImageService: Deleted image at $photoPath');
      }
    } catch (e) {
      debugPrint('ImageService.deleteImage error: $e');
    }
  }

  /// Android에서 MainActivity 종료 후 복구를 위한 Lost Data 처리
  Future<LostDataResponse?> retrieveLostData() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;
      return response;
    } catch (e) {
      debugPrint('ImageService.retrieveLostData error: $e');
      return null;
    }
  }
}

/// 크롭 페이지 (순수 Flutter UI - iOS/Android 동일)
class _CropPage extends StatefulWidget {
  final Uint8List imageBytes;
  
  const _CropPage({required this.imageBytes});

  @override
  State<_CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<_CropPage> {
  final _controller = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('사진 편집'),
        automaticallyImplyLeading: false, // Remove back button
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              controller: _controller,
              image: widget.imageBytes,
              aspectRatio: 1, // 정사각형 강제
              initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                size: 0.5, // 초기 크롭 영역을 이미지의 50%로 설정
                aspectRatio: 1.0,
              ),
              withCircleUi: false,
              baseColor: Colors.black,
              maskColor: Colors.black.withValues(alpha: 0.7),
              // 3x3 그리드 라인 (삼분할선)
              interactive: true,
              willUpdateScale: (scale) => true,
              progressIndicator: const CircularProgressIndicator(color: Colors.white),
              cornerDotBuilder: (size, edgeAlignment) => SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Container(
                    width: size * 0.5, // 50% smaller visual
                    height: size * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 그리드 라인 빌더
              overlayBuilder: (context, rect) {
                return CustomPaint(
                  size: Size(rect.width, rect.height),
                  painter: _GridPainter(),
                );
              },
              onCropped: (result) {
                setState(() => _isCropping = false);
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    Navigator.pop(context, croppedImage);
                  case CropFailure(:final cause):
                    debugPrint('Crop failed: $cause');
                    Navigator.pop(context);
                }
              },
              onStatusChanged: (status) {
                if (status == CropStatus.cropping) {
                  setState(() => _isCropping = true);
                }
              },
            ),
          ),
          // Bottom Buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Done Button
                  Expanded(
                    flex: 2,
                    child: _isCropping
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : FilledButton(
                            onPressed: () => _controller.crop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '완료',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3x3 삼분할 그리드 라인을 그리는 Painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 세로선 2개 (1/3, 2/3 지점)
    final thirdWidth = size.width / 3;
    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      paint,
    );

    // 가로선 2개 (1/3, 2/3 지점)
    final thirdHeight = size.height / 3;
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
