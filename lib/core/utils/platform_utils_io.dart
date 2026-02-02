import 'package:flutter/material.dart';
import 'dart:io' as io;

class PlatformUtilsImpl {
  static Future<bool> fileExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      return await io.File(path).exists();
    } catch (_) {
      return false;
    }
  }

  static ImageProvider? getImageProvider(String path) {
    return FileImage(io.File(path));
  }

  static Future<void> evictImage(String path) async {
    await FileImage(io.File(path)).evict();
  }
}
