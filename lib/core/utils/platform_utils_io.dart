import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PlatformUtilsImpl {
  static String? _appDocDir;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _appDocDir = directory.path;
  }

  /// 상대 경로를 현재 앱 문서 디렉토리 기반의 절대 경로로 변환
  static Future<String?> resolvePath(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    
    // 이미 절대 경로인 경우
    if (relativePath.startsWith('/')) return relativePath;
    
    // 캐시된 경로가 있으면 사용
    if (_appDocDir != null) {
      return p.join(_appDocDir!, relativePath);
    }
    
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
  
  static ImageProvider? getImageProviderSync(String path) {
    if (path.isEmpty) return null;
    
    String? absolutePath;
    if (path.startsWith('/')) {
      absolutePath = path;
    } else if (_appDocDir != null) {
      absolutePath = p.join(_appDocDir!, path);
    }
    
    if (absolutePath != null) {
      return FileImage(io.File(absolutePath));
    }
    return null;
  }

  static ImageProvider? getImageProvider(String path) {
    // 동기 버전 (구버전 호환)
    return getImageProviderSync(path);
  }

  static Future<void> evictImage(String path) async {
    final absolutePath = path.startsWith('/') ? path : await resolvePath(path);
    if (absolutePath != null) {
      await FileImage(io.File(absolutePath)).evict();
    }
  }
}
