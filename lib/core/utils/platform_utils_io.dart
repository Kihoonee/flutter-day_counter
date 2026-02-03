import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PlatformUtilsImpl {
  /// 상대 경로를 현재 앱 문서 디렉토리 기반의 절대 경로로 변환
  static Future<String?> resolvePath(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    
    // 이미 절대 경로인 경우 (하위 호환성 - 필요시 활성화)
    // if (relativePath.startsWith('/')) return relativePath;
    
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, relativePath);
  }

  static Future<bool> fileExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      // 상대 경로인 경우 절대 경로로 변환
      final absolutePath = path.startsWith('/') ? path : await resolvePath(path);
      if (absolutePath == null) return false;
      return await io.File(absolutePath).exists();
    } catch (_) {
      return false;
    }
  }

  static Future<ImageProvider?> getImageProviderAsync(String path) async {
    // 상대 경로인 경우 절대 경로로 변환
    final absolutePath = path.startsWith('/') ? path : await resolvePath(path);
    if (absolutePath == null) return null;
    return FileImage(io.File(absolutePath));
  }

  static ImageProvider? getImageProvider(String path) {
    // 동기 버전: 절대 경로만 지원 (기존 호환성)
    if (!path.startsWith('/')) return null;
    return FileImage(io.File(path));
  }

  static Future<void> evictImage(String path) async {
    final absolutePath = path.startsWith('/') ? path : await resolvePath(path);
    if (absolutePath != null) {
      await FileImage(io.File(absolutePath)).evict();
    }
  }
}
