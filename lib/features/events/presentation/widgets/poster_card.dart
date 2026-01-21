import 'package:flutter/material.dart';

class PosterTheme {
  final Color bg;
  final Color fg;
  final IconData icon;
  const PosterTheme(this.bg, this.fg, this.icon);
}

const posterThemes = <PosterTheme>[
  PosterTheme(Color(0xFF63B3FF), Color(0xFF0B3B6E), Icons.flight_rounded),
  PosterTheme(Color(0xFFFF6B6B), Color(0xFF3B0B0B), Icons.cake_rounded),
  PosterTheme(Color(0xFF7C5CFF), Color(0xFF130B3B), Icons.work_rounded),
  PosterTheme(Color(0xFFFFD166), Color(0xFF3B2A0B), Icons.celebration_rounded),
  PosterTheme(
    Color(0xFF4ECDC4),
    Color(0xFF0B3B38),
    Icons.directions_run_rounded,
  ),
];

class PosterCard extends StatelessWidget {
  final String title;
  final String dateLine;
  final String dText;
  final int themeIndex;
  final VoidCallback? onTap;

  const PosterCard({
    super.key,
    required this.title,
    required this.dateLine,
    required this.dText,
    required this.themeIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = posterThemes[themeIndex % posterThemes.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              blurRadius: 22,
              offset: Offset(0, 14),
              color: Color(0x1A000000),
            ),
          ],
        ),
        child: Stack(
          children: [
            // "cut-paper" 느낌의 간단 도형
            Positioned(
              right: -30,
              top: 44,
              child: Transform.rotate(
                angle: 0.18,
                child: Container(
                  width: 160,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 64,
              child: Transform.rotate(
                angle: -0.15,
                child: Container(
                  width: 160,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1B8).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: t.fg.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: t.fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(t.icon, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateLine,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.fg.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dText,
                    style: const TextStyle(
                      fontSize: 44,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                ),
                const Text(
                  'days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
