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
  Future<String?> pickAndCropImage(BuildContext context) async {
    try {
      debugPrint('ImageService: pickAndCropImage start');
      // 1. 갤러리에서 이미지 선택
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        debugPrint('ImageService: Picker returned null');
        return null;
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
        debugPrint('ImageService: Cropped bytes null (cancelled)');
        return null;
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('사진 편집'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isCropping)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _controller.crop(),
              child: const Text(
                '완료',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Crop(
        controller: _controller,
        image: widget.imageBytes,
        aspectRatio: 1, // 정사각형 강제
        withCircleUi: false,
        baseColor: Colors.black,
        maskColor: Colors.black.withValues(alpha: 0.7),
        cornerDotBuilder: (size, edgeAlignment) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
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
    );
  }
}
