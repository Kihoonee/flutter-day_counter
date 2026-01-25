import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PosterTheme {
  final Color bg;
  final Color fg;
  const PosterTheme(this.bg, this.fg);
}

// HugeIcons 리스트 (인덱스로 관리)
const eventIcons = <dynamic>[
  HugeIcons.strokeRoundedFavourite,      // 0: 하트
  HugeIcons.strokeRoundedBirthdayCake,    // 1: 케이크
  HugeIcons.strokeRoundedNaturalFood,     // 2: 나뭇잎/자연
  HugeIcons.strokeRoundedDroplet,         // 3: 물방울
  HugeIcons.strokeRoundedMoon02,          // 4: 달
  HugeIcons.strokeRoundedAirplane01,      // 5: 비행기
  HugeIcons.strokeRoundedGift,            // 6: 선물
  HugeIcons.strokeRoundedSun01,           // 7: 해
  HugeIcons.strokeRoundedNote01,          // 8: 문서/노트
  HugeIcons.strokeRoundedCoffee01,        // 9: 커피
  HugeIcons.strokeRoundedUser,            // 10: 반려동물
  HugeIcons.strokeRoundedBook01,          // 11: 학교
  HugeIcons.strokeRoundedDumbbell01,      // 12: 운동
  HugeIcons.strokeRoundedMusicNote01,     // 13: 음악
  HugeIcons.strokeRoundedMoney03,         // 14: 돈
  HugeIcons.strokeRoundedHome01,          // 15: 집
  HugeIcons.strokeRoundedStar,            // 16: 별
  HugeIcons.strokeRoundedBriefcase01,     // 17: 업무
  HugeIcons.strokeRoundedDish01,          // 18: 식사
  HugeIcons.strokeRoundedCar01,           // 19: 차
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
  final int todoCount;
  final VoidCallback? onTap;

  const PosterCard({
    super.key,
    required this.title,
    required this.dateLine,
    required this.dText,
    required this.themeIndex,
    this.iconIndex = 0,
    this.todoCount = 0,
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max, 
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
                                    fontSize: 22, 
                                    color: fgColor, 
                                  ),
                                ),
                                const SizedBox(height: 8), 
                                Padding(
                                  padding: const EdgeInsets.only(left: 4), 
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateLine,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontSize: 16, 
                                          color: fgColor.withOpacity(0.85),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (todoCount > 0) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: fgColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons.strokeRoundedTask01,
                                                color: fgColor.withOpacity(0.8),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$todoCount',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: fgColor.withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(
                              icon: iconData,
                              color: fgColor,
                              size: 26, 
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),

                      // Bottom Row: D-Day Count (right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // D-Day text (right aligned)
                          Text(
                            dText,
                            style: theme.textTheme.displaySmall?.copyWith( 
                              fontSize: 48, 
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.5,
                              height: 1.0,
                              color: isPast 
                                  ? fgColor.withOpacity(0.6) 
                                  : fgColor, 
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
