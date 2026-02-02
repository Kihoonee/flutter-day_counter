import 'package:flutter/material.dart';

class PlatformUtilsImpl {
  static Future<bool> fileExists(String? path) async {
    return false;
  }

  static ImageProvider? getImageProvider(String path) {
    return null;
  }

  static Future<void> evictImage(String path) async {
    // No-op on web
  }
}
