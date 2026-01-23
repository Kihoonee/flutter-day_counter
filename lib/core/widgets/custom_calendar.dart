import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showCustomCalendar(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: CustomCalendar(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    ),
  );
}

class CustomCalendar extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomCalendar({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  bool _isYearPicker = false;
  ScrollController? _yearScrollController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  void dispose() {
    _yearScrollController?.dispose();
    super.dispose();
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
  }

  void _changeYear(int year) {
    setState(() {
      _currentMonth = DateTime(year, _currentMonth.month);
      _isYearPicker = false;
      _yearScrollController?.dispose();
      _yearScrollController = null;
    });
  }

  void _toggleYearPicker() {
    setState(() {
      _isYearPicker = !_isYearPicker;
      if (_isYearPicker) {
        // Calculate scroll offset to center current year
        final currentYear = DateTime.now().year;
        final startYear = currentYear - 50;
        final targetIndex = _currentMonth.year - startYear;
        
        if (targetIndex >= 0 && targetIndex < 100) {
          // Layout calculations
          // Width: 320 - 48(padding) = 272
          // Checks: (272 - 2*12)/3 = 82.66 width per item
          // Height: 82.66 / 1.5 = 55.11
          // Row Height: 55.11 + 12(spacing) = 67.11
          
          final rowIndex = targetIndex ~/ 3;
          final rowHeight = 67.11;
          final viewHeight = 300.0;
          
          double offset = (rowIndex * rowHeight) - (viewHeight / 2) + (rowHeight / 2);
          if (offset < 0) offset = 0;
          
          _yearScrollController = ScrollController(initialScrollOffset: offset);
        } else {
          _yearScrollController = ScrollController();
        }
      } else {
        _yearScrollController?.dispose();
        _yearScrollController = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            if (_isYearPicker)
              SizedBox(
                height: 300,
                child: _buildYearPicker(theme),
              )
            else ...[
              _buildWeekDays(theme),
              const SizedBox(height: 12),
              _buildDaysGrid(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!_isYearPicker)
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: Icon(Icons.chevron_left_rounded, color: theme.colorScheme.onSurface),
          )
        else
          const SizedBox(width: 48),

        GestureDetector(
          onTap: _toggleYearPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('yyyy. MMMM').format(_currentMonth),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isYearPicker ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),

        if (!_isYearPicker)
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildYearPicker(ThemeData theme) {
    final currentYear = DateTime.now().year;
    return GridView.builder(
      controller: _yearScrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        final year = currentYear - 50 + index;
        final isSelected = year == _currentMonth.year;
        final isToday = year == DateTime.now().year;

        return GestureDetector(
          onTap: () => _changeYear(year),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                  : null,
            ),
            child: Text(
              '$year',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekDays(ThemeData theme) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => SizedBox(
                width: 32,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid(ThemeData theme) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    
    final totalCells = daysInMonth + firstDayOffset;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final day = index - firstDayOffset + 1;

              if (day < 1 || day > daysInMonth) {
                return const SizedBox(width: 32, height: 32);
              }

              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  Navigator.pop(context, date);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : (isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
