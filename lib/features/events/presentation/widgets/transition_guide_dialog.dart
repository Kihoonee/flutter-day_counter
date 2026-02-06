import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:days_plus/l10n/app_localizations.dart';

/// 할일 → 메모 전환 안내 다이얼로그
/// 
/// 이벤트가 D-Day를 맞이하여 isPast 상태가 되었을 때 처음 1회만 표시됩니다.
/// 감성적인 메시지와 부드러운 애니메이션으로 자연스러운 전환을 안내합니다.
Future<void> showTransitionGuideDialog(BuildContext context, String eventTitle) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // 반드시 버튼을 눌러야 닫힘
    builder: (context) => _TransitionGuideDialog(eventTitle: eventTitle),
  );
}

class _TransitionGuideDialog extends StatefulWidget {
  final String eventTitle;
  
  const _TransitionGuideDialog({required this.eventTitle});

  @override
  State<_TransitionGuideDialog> createState() => _TransitionGuideDialogState();
}

class _TransitionGuideDialogState extends State<_TransitionGuideDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // 다이얼로그 표시 직후 애니메이션 시작
    _controller.forward();
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedStar,
                    color: theme.colorScheme.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                // 타이틀
                Text(
                  l10n.transitionGuideTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 본문
                Text(
                  l10n.transitionGuideBody(widget.eventTitle),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(
                      l10n.transitionGuideButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
