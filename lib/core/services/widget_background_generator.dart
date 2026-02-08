import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/events/presentation/widgets/poster_card.dart';

/// Generates widget background images from PosterCard visuals.
/// This allows Home Screen Widgets to display the exact same visual
/// (waves, gradients, patterns) as the app's event cards.
class WidgetBackgroundGenerator {
  /// Directory name for widget background images
  static const String _widgetImagesDir = 'widget_backgrounds';

  /// Generates a background image for the given event parameters.
  /// Returns the file path of the saved image, or null on failure.
  static Future<String?> generateBackground({
    required int themeIndex,
    required Size size,
    String eventId = 'default',
  }) async {
    if (kIsWeb) return null;

    try {
      // Create offscreen widget for rendering
      final widget = _BackgroundOnlyCard(themeIndex: themeIndex);

      // Create a repaint boundary key
      final GlobalKey repaintKey = GlobalKey();

      // Build the widget tree offscreen
      final renderWidget = RepaintBoundary(
        key: repaintKey,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: widget,
        ),
      );

      // Use a custom pipeline for offscreen rendering
      final bytes = await _captureWidget(renderWidget, size);
      if (bytes == null) return null;

      // Save to file
      final filePath = await _saveImage(bytes, eventId);
      return filePath;
    } catch (e) {
      debugPrint('WIDGET_BG_GEN: Error generating background: $e');
      return null;
    }
  }

  /// Captures a widget background to PNG bytes using direct canvas painting
  static Future<Uint8List?> _captureWidget(Widget widget, Size size) async {
    try {
      // Use PictureRecorder to draw directly
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

      // Draw background color and pattern directly
      // Since widget is always a _BackgroundOnlyCard, we know it uses CustomPaint
      // Instead of rendering the full widget, we paint directly using the painter
      
      // Create the painter and paint directly onto the canvas
      final themeIndex = widget is _BackgroundOnlyCard ? widget.themeIndex : 0;
      final pTheme = posterThemes[themeIndex % posterThemes.length];
      
      // Draw background color
      final bgPaint = Paint()..color = pTheme.bg;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      );
      canvas.drawRRect(rrect, bgPaint);
      
      // Draw patterns
      final patternPainter = _SimplifiedPatternPainter(
        overlayColor: Colors.white,
        seed: themeIndex,
      );
      patternPainter.paint(canvas, size);
      
      // Convert recording to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt() * 2, size.height.toInt() * 2); // 2x for retina
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('WIDGET_BG_GEN: Error capturing widget: $e');
      return null;
    }
  }

  /// Saves image bytes to the shared directory
  static Future<String?> _saveImage(Uint8List bytes, String eventId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final widgetDir = Directory('${appDir.path}/$_widgetImagesDir');

      if (!await widgetDir.exists()) {
        await widgetDir.create(recursive: true);
      }

      final fileName = 'widget_bg_$eventId.png';
      final file = File('${widgetDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('WIDGET_BG_GEN: Saved background to ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('WIDGET_BG_GEN: Error saving image: $e');
      return null;
    }
  }

  /// Gets the shared directory path for iOS App Groups
  static Future<String?> getSharedDirectoryPath() async {
    if (kIsWeb) return null;
    try {
      if (Platform.isIOS) {
        // For iOS, we need to use the App Group container
        // This requires additional native code or home_widget's built-in support
        return null; // Will use HomeWidget.saveWidgetData with file path
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        return '${appDir.path}/$_widgetImagesDir';
      }
    } catch (e) {
      debugPrint('WIDGET_BG_GEN: Error getting shared directory: $e');
      return null;
    }
  }
}

/// A simplified version of PosterCard that only renders the background pattern.
/// Used for generating widget background images without text content.
class _BackgroundOnlyCard extends StatelessWidget {
  final int themeIndex;

  const _BackgroundOnlyCard({required this.themeIndex});

  @override
  Widget build(BuildContext context) {
    final pTheme = posterThemes[themeIndex % posterThemes.length];

    return Container(
      decoration: BoxDecoration(
        color: pTheme.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _SimplifiedPatternPainter(
            overlayColor: Colors.white,
            seed: themeIndex,
          ),
        ),
      ),
    );
  }
}

/// Simplified pattern painter (static version without animation)
class _SimplifiedPatternPainter extends CustomPainter {
  final Color overlayColor;
  final int seed;

  _SimplifiedPatternPainter({required this.overlayColor, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    _drawWavyGradient(canvas, size);
    _drawDroplets(canvas, size);
  }

  void _drawWavyGradient(Canvas canvas, Size size) {
    final random = _SeededRandom(seed);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          overlayColor.withOpacity(0.0),
          overlayColor.withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final startY = size.height * (0.4 + random.nextDouble() * 0.2);
    path.moveTo(0, startY);

    final cp1x = size.width * (0.25 + random.nextDouble() * 0.1);
    final cp1y = size.height * (random.nextDouble() * 0.5);
    final cp2x = size.width * (0.65 + random.nextDouble() * 0.1);
    final cp2y = size.height * (0.5 + random.nextDouble() * 0.5);
    final endY = size.height * (0.4 + random.nextDouble() * 0.3);

    path.cubicTo(cp1x, cp1y, cp2x, cp2y, size.width, endY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDroplets(Canvas canvas, Size size) {
    final random = _SeededRandom(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    final count = 5 + (seed % 4);
    random.nextDouble(); // Burn values for consistency
    random.nextDouble();

    for (int i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = size.height * 0.3 + random.nextDouble() * (size.height * 0.7);
      final radius = 3.0 + random.nextDouble() * 6.0;

      paint.color = overlayColor.withOpacity(0.1 + random.nextDouble() * 0.2);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SimplifiedPatternPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

/// Simple seeded random for consistent pattern generation
class _SeededRandom {
  int _seed;

  _SeededRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return _seed / 0x7FFFFFFF;
  }
}
