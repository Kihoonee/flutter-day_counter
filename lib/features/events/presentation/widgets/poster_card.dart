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

    // Determine if Future or Past based on dText
    // 보통 'D-DAY', 'D-5' (미래), 'D+3' (과거)
    final isDDay = dText == 'D-Day';
    final isPast = dText.contains('+');

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
                  padding: const EdgeInsets.all(16), // Reduced from 24
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
                                    fontSize: 22, // Fixed larger size
                                    color: fgColor, 
                                  ),
                                ),
                                const SizedBox(height: 8), 
                                Text(
                                  dateLine,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 16, // Explicit size
                                    color: fgColor.withOpacity(0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10), // Reduced from 12
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: fgColor,
                              size: 26, 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // Reduced from 24
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            dText,
                            style: theme.textTheme.displaySmall?.copyWith( // Use displaySmall (smaller than displayMedium but big enough)
                              fontSize: 36, // Specific visual weight
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isPast 
                                  ? fgColor.withOpacity(0.5) // Past: Dimmed more
                                  : fgColor, 
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isDDay)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'days',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: fgColor.withOpacity(isPast ? 0.5 : 0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          if (isPast) // Add visual tag for past
                             Padding(
                               padding: const EdgeInsets.only(left: 8, bottom: 6),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: fgColor.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: Text(
                                   'PAST',
                                   style: TextStyle(
                                     color: fgColor.withOpacity(0.6),
                                     fontSize: 10,
                                     fontWeight: FontWeight.bold,
                                   ),
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
          overlayColor.withOpacity(0.0), // Fully transparent top
          overlayColor.withOpacity(0.4), // Stronger bottom
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    
    // S-Curve Wave Logic
    final startY = size.height * (0.4 + random.nextDouble() * 0.2); // 40~60%
    path.moveTo(0, startY);

    // First Control Point (Upwards/Downwards)
    final cp1x = size.width * (0.25 + random.nextDouble() * 0.1); 
    final cp1y = size.height * (random.nextDouble() * 0.5); // Top half

    // Second Control Point (Opposite)
    final cp2x = size.width * (0.65 + random.nextDouble() * 0.1);
    final cp2y = size.height * (0.5 + random.nextDouble() * 0.5); // Bottom half

    final endY = size.height * (0.4 + random.nextDouble() * 0.3);

    path.cubicTo(cp1x, cp1y, cp2x, cp2y, size.width, endY);
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDroplets(Canvas canvas, Size size) {
    final random = Random(seed); 
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw fewer, subtle droplets
    final count = 5 + random.nextInt(4);
    
    random.nextDouble(); random.nextDouble(); // Burn

    for (int i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = size.height * 0.3 + random.nextDouble() * (size.height * 0.7);
      final radius = 3.0 + random.nextDouble() * 6.0;
      
      paint.color = overlayColor.withOpacity(0.1 + random.nextDouble() * 0.2);
      
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor || oldDelegate.seed != seed;
  }
}
