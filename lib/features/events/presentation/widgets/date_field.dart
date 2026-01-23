import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/custom_calendar.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final Future<void> Function() onTap;
  final String? helper;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = DateFormat('yyyy.MM.dd (EEE)', 'en_US').format(value);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium, // Bold 제거 (Normal)
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface, // Bold 제거
                      ),
                    ),
                    if (helper != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        helper!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showCustomCalendar(
    context,
    initialDate: initial,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}
