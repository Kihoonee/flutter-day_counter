import 'dart:math';
import 'package:flutter/material.dart';

class PosterTheme {
  final Color bg;
  final Color fg;
  const PosterTheme(this.bg, this.fg);
}

// 아이콘 리스트 (인덱스로 관리)
const eventIcons = <IconData>[
  Icons.favorite_rounded,      // 0: 하트
  Icons.cake_rounded,          // 1: 케이크
  Icons.eco_rounded,           // 2: 나뭇잎
  Icons.water_drop_rounded,    // 3: 물방울
  Icons.bedtime_rounded,       // 4: 달
  Icons.flight_rounded,        // 5: 비행기
  Icons.card_giftcard_rounded, // 6: 선물
  Icons.light_mode_rounded,    // 7: 해
  Icons.article_rounded,       // 8: 문서
  Icons.coffee_rounded,        // 9: 커피
  Icons.pets_rounded,          // 10: 반려동물
  Icons.school_rounded,        // 11: 학교
  Icons.fitness_center_rounded,// 12: 운동
  Icons.music_note_rounded,    // 13: 음악
  Icons.monetization_on_rounded,// 14: 돈
  Icons.home_rounded,          // 15: 집
  Icons.star_rounded,          // 16: 별
  Icons.work_rounded,          // 17: 일
  Icons.local_dining_rounded,  // 18: 식사
  Icons.directions_car_rounded,// 19: 차
];

const posterThemes = <PosterTheme>[
  PosterTheme(Color(0xFFFFCDD2), Color(0xFF5D1010)), // Red
  PosterTheme(Color(0xFFFFCC80), Color(0xFF5D3000)), // Orange
  PosterTheme(Color(0xFFC8E6C9), Color(0xFF1B5E20)), // Green
  PosterTheme(Color(0xFFB2DFDB), Color(0xFF004D40)), // Teal
  PosterTheme(Color(0xFFD1C4E9), Color(0xFF311B92)), // Deep Purple
  
  // Existing Additional
  PosterTheme(Color(0xFF90CAF9), Color(0xFF0D47A1)), // Blue
  PosterTheme(Color(0xFFF48FB1), Color(0xFF880E4F)), // Pink
  PosterTheme(Color(0xFFFFF59D), Color(0xFFF57F17)), // Yellow
  PosterTheme(Color(0xFFCFD8DC), Color(0xFF263238)), // Blue Grey
  PosterTheme(Color(0xFFBCAAA4), Color(0xFF3E2723)), // Brown

  // New Themes for User
  PosterTheme(Color(0xFFF0F4C3), Color(0xFF827717)), // Lime
  PosterTheme(Color(0xFFB2EBF2), Color(0xFF006064)), // Cyan
  PosterTheme(Color(0xFFC5CAE9), Color(0xFF1A237E)), // Indigo
  PosterTheme(Color(0xFFEA80FC), Color(0xFF4A148C)), // PurpleAccent
  PosterTheme(Color(0xFFFFAB91), Color(0xFFBF360C)), // DeepOrange
];

class PosterCard extends StatelessWidget {
  final String title;
  final String dateLine;
  final String dText;
  final int themeIndex;
  final int iconIndex;
  final VoidCallback? onTap;

  const PosterCard({
    super.key,
    required this.title,
    required this.dateLine,
    required this.dText,
    required this.themeIndex,
    this.iconIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Select theme based on index (Safe lookup)
    final pTheme = posterThemes[themeIndex % posterThemes.length];
    final fgColor = pTheme.fg;

    // Select icon based on index (Safe lookup)
    final iconData = eventIcons[iconIndex % eventIcons.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12), // Horizontal space for shadow + Bottom space
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: pTheme.bg, // Main Pastel Background
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: pTheme.fg.withOpacity(0.3), // Stronger, visible colored shadow
                blurRadius: 6, // Tighter
                offset: const Offset(0, 4), // Lower but shorter
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background Pattern (White Wavy Gradient + Droplets)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PatternPainter(Colors.white, themeIndex),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: fgColor, // Contrast Text
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateLine,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: fgColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4), // Brighter overlay
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: fgColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            dText,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: fgColor, // Highlight D-Day text
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              'days',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: fgColor.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color overlayColor;
  final int seed;

  _PatternPainter(this.overlayColor, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWavyGradient(canvas, size);
    _drawDroplets(canvas, size);
  }

  void _drawWavyGradient(Canvas canvas, Size size) {
    final random = Random(seed);
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          overlayColor.withOpacity(0.0),
          overlayColor.withOpacity(0.35),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    
    // Randomize start height (0.5 to 0.6)
    final startY = size.height * (0.5 + random.nextDouble() * 0.1);
    path.moveTo(0, startY);

    // Randomize control point (X: 0.3-0.7, Y: 0.1-0.4)
    final controlX = size.width * (0.3 + random.nextDouble() * 0.4);
    final controlY = size.height * (0.1 + random.nextDouble() * 0.3);

    // Randomize end point (0.55 to 0.7)
    final endY = size.height * (0.55 + random.nextDouble() * 0.15);

    path.quadraticBezierTo(controlX, controlY, size.width, endY);
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDroplets(Canvas canvas, Size size) {
    final random = Random(seed); 
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw 6-10 droplets
    final count = 6 + random.nextInt(5);

    // Consume randoms used in weave generation to keep sync if we cared, 
    // but independent Random(seed) instance is safer if order matters. 
    // Actually we re-instantiated Random(seed) so it's fresh sequence. 
    // To mix them, we should burn the first few randoms used by wave or just share the instance.
    // Let's burn the numbers used in wave to ensure droplets are distinct from wave logic? 
    // No need, they are just random numbers.
    
    // Note: We need to ensure Droplets are drawn "around" the wave area generally.
    // Since wave is random, we can't easily bound perfectly without passing the path.
    // But generalized bottom-half random is fine for this aesthetic.
    
    // Burn the 4 doubles used in _drawWavyGradient to shift the sequence
    random.nextDouble(); random.nextDouble(); random.nextDouble(); random.nextDouble(); 

    for (int i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = size.height * 0.4 + random.nextDouble() * (size.height * 0.6);
      final radius = 5.0 + random.nextDouble() * 10.0;
      
      paint.color = overlayColor.withOpacity(0.15 + random.nextDouble() * 0.3);
      
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor || oldDelegate.seed != seed;
  }
}
