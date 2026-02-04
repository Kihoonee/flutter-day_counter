import 'package:flutter/foundation.dart';
import '../../../../core/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:days_plus/l10n/app_localizations.dart';

import 'dart:math';

class PosterTheme {
  final Color bg;
  final Color fg;
  const PosterTheme(this.bg, this.fg);
}

// HugeIcons 리스트 (인덱스로 관리)
const List<dynamic> eventIcons = [
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

class PosterCard extends StatefulWidget {
  final String title;
  final String dateLine;
  final String dText;
  final int themeIndex;
  final int iconIndex;
  final int todoCount;
  final String? photoPath;
  final int widgetLayoutType;
  final VoidCallback? onTap;

  const PosterCard({
    super.key,
    required this.title,
    required this.dateLine,
    required this.dText,
    required this.themeIndex,
    this.iconIndex = 0,
    this.todoCount = 0,
    this.photoPath,
    this.widgetLayoutType = 0,
    this.onTap,
  });

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ImageProvider? _imageProvider;
  String? _lastLoadedPath;

  @override
  void initState() {
    super.initState();
    // Speed up: 6 seconds loop instead of 15
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _loadImage();
  }

  @override
  void didUpdateWidget(PosterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoPath != oldWidget.photoPath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.photoPath == null || widget.photoPath!.isEmpty) {
      if (mounted) {
        setState(() {
          _imageProvider = null;
          _lastLoadedPath = null;
        });
      }
      return;
    }

    if (widget.photoPath == _lastLoadedPath) return;

    final provider = await PlatformUtilsImpl.getImageProviderAsync(widget.photoPath!);
    if (mounted) {
      setState(() {
        _imageProvider = provider;
        _lastLoadedPath = widget.photoPath;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Select theme based on index (Safe lookup)
    final pTheme = posterThemes[widget.themeIndex % posterThemes.length];
    
    // UI Refinement v2: Unified Softer Gray for better readability and minimalist feel
    const fgColor = Color(0xFF4A4A4A); 

    // Select icon based on index (Safe lookup)
    final iconData = eventIcons[widget.iconIndex % eventIcons.length];

    // Determine if Future or Past based on dText
    final isPast = widget.dText.contains('+');

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: pTheme.bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: pTheme.fg.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Background Pattern - Animated
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _PatternPainter(
                        Colors.white, 
                        widget.themeIndex,
                        animationValue: _controller.value,
                      ),
                    );
                  },
                ),
              ),

              // 2. Ripple Effect Layer
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              // 3. Content Layout
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildDDayEmphasis(theme, fgColor, iconData, isPast),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDDayEmphasis(ThemeData theme, Color fgColor, dynamic iconData, bool isPast) {
    return Stack(
      children: [
        const SizedBox.expand(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 48.0),
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: fgColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.dateLine,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                color: fgColor.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.todoCount > 0) _buildTodoBadge(fgColor, widget.todoCount),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: _buildIcon(fgColor, iconData),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: _buildDDayText(theme, fgColor),
        ),
        if (widget.photoPath != null && widget.photoPath!.isNotEmpty)
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildPhoto(),
          ),
      ],
    );
  }

  Widget _buildIcon(Color fgColor, dynamic iconData) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: HugeIcon(
        icon: iconData as List<List<dynamic>>,
        color: fgColor,
        size: 24,
      ),
    );
  }

  Widget _buildTodoBadge(Color fgColor, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
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
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fgColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDDayText(ThemeData theme, Color fgColor, {double? fontSize}) {
    return Text(
      widget.dText,
      textAlign: TextAlign.left,
      style: theme.textTheme.displaySmall?.copyWith(
        fontSize: fontSize ?? (widget.photoPath != null ? 32 : 40),
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.0,
        color: fgColor,
      ),
    );
  }

  Widget _buildPhoto({double size = 72}) {
    if (_imageProvider == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: _imageProvider!,
          key: ValueKey(widget.photoPath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color overlayColor;
  final int seed;
  final double animationValue; // 0.0 ~ 1.0

  _PatternPainter(this.overlayColor, this.seed, {this.animationValue = 0.0});

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
          overlayColor.withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    
    // Increase visibility: Larger shift and amplitude
    final waveShift = sin(animationValue * 2 * pi) * 45.0;
    final waveAmplitude = 15.0 * (1.0 + cos(animationValue * pi) * 0.3);

    final startY = size.height * (0.4 + random.nextDouble() * 0.2) + (waveShift * 0.2);
    path.moveTo(0, startY);

    // First Control Point
    final cp1x = size.width * (0.25 + random.nextDouble() * 0.1) + waveShift; 
    final cp1y = size.height * (random.nextDouble() * 0.5) - waveAmplitude;

    // Second Control Point
    final cp2x = size.width * (0.65 + random.nextDouble() * 0.1) - waveShift;
    final cp2y = size.height * (0.5 + random.nextDouble() * 0.5) + waveAmplitude;

    final endY = size.height * (0.4 + random.nextDouble() * 0.3) - (waveShift * 0.1);

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

    final count = 5 + random.nextInt(4);
    
    random.nextDouble(); random.nextDouble(); // Burn

    // Subtle drift for droplets based on animation
    final driftX = sin(animationValue * 2 * pi) * 5.0;
    final driftY = cos(animationValue * 2 * pi) * 5.0;

    for (int i = 0; i < count; i++) {
      final dx = (random.nextDouble() * size.width) + driftX;
      final dy = (size.height * 0.3 + random.nextDouble() * (size.height * 0.7)) + driftY;
      final radius = 3.0 + random.nextDouble() * 6.0;
      
      paint.color = overlayColor.withOpacity(0.1 + random.nextDouble() * 0.2);
      
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor || 
           oldDelegate.seed != seed || 
           oldDelegate.animationValue != animationValue;
  }
}
