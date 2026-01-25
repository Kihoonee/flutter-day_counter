import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

/// ModernFAB: A premium, squircle-shaped Floating Action Button.
/// Uses a blurred background (Glassmorphism concept) or solid color with soft shadows.
class ModernFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final dynamic icon; // Changed from IconData to dynamic to support HugeIcons
  final String? tooltip;

  const ModernFAB({
    super.key,
    required this.onPressed,
    required this.icon, // Remove default value to avoid const issues with dynamic
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Glassmorphic / Soft White Design
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24), // Slightly more rounded squircle
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              // Translucent White Background
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Very soft shadow
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15), // Subtle colored glow
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
               borderRadius: BorderRadius.circular(24),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                 child: Center(
                   // Gradient or Solid Icon? Solid Dark Grey is clean.
                   child: HugeIcon(
                     icon: icon,
                     size: 28, 
                     color: const Color(0xFF2C2C2C), // Soft Black
                   ),
                 ),
               ),
            ),
          ),
        ),
      ),
    );
  }
}
