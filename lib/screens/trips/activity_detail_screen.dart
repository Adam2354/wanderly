import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/activity_model.dart';
import '../../data/providers/activity_provider.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final ActivityModel activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  late ActivityModel _activity;
  late final TextEditingController _noteController;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Widget _getImageWidget() {
    if (_activity.imagePath == null || _activity.imagePath!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 64, color: Colors.grey),
      );
    }

    final imagePath = _activity.imagePath!;
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    }

    return Image.file(
      File(imagePath),
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported),
        );
      },
    );
  }

  String _statusLabel(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return 'Upcoming';
      case ActivityStatus.ongoing:
        return 'Ongoing';
      case ActivityStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return const Color(0xFFF59E0B);
      case ActivityStatus.ongoing:
        return const Color(0xFF2F4BB9);
      case ActivityStatus.completed:
        return const Color(0xFF10B981);
    }
  }

  DateTime _dateForStatus(ActivityStatus status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (status) {
      case ActivityStatus.completed:
        return today.subtract(const Duration(days: 1));
      case ActivityStatus.ongoing:
        return today;
      case ActivityStatus.upcoming:
        return today.add(const Duration(days: 1));
    }
  }

  Future<void> _updateStatus(ActivityStatus status) async {
    final updated = _activity.copyWith(date: _dateForStatus(status));

    if (_activity.id != null) {
      await ref
          .read(activitiesProvider.notifier)
          .updateActivity(_activity.id!, updated);
    }

    setState(() {
      _activity = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);
    final status = getActivityStatus(_activity, DateTime.now());
    final statusColor = _statusColor(status);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _getImageWidget(),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activity.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F4BB9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _activity.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                // Location and Date Info
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                                color: textColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activity.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: textColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activity.date != null
                                      ? _formatFullDate(_activity.date!)
                                      : 'Belum dijadwalkan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Detail Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _activity.notes.isNotEmpty
                            ? '${_activity.notes}\n\nKamu bisa melengkapi rute terbaik, estimasi waktu kunjungan, dan rekomendasi spot foto favorit agar perjalanan lebih terarah.'
                            : 'Belum ada catatan detail untuk aktivitas ini. Tambahkan informasi penting seperti durasi kunjungan, rekomendasi waktu terbaik, serta tips singkat agar perjalananmu lebih nyaman.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ubah Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: DropdownButton<ActivityStatus>(
                          value: status,
                          underline: const SizedBox(),
                          isExpanded: true,
                          icon: Icon(Icons.expand_more, color: textColor),
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(color: textColor, fontSize: 14),
                          items: ActivityStatus.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(_statusLabel(value)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            _updateStatus(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (status == ActivityStatus.completed) ...[
                        Text(
                          'Rating',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(5, (index) {
                            final isActive = index < _rating;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  isActive ? Icons.star : Icons.star_border,
                                  size: 26,
                                  color: isActive
                                      ? const Color(0xFFF59E0B)
                                      : subTextColor,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                      ],

                      Text(
                        'Catatan Tambahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tulis catatan singkat perjalananmu...',
                          hintStyle: TextStyle(color: subTextColor),
                          filled: true,
                          fillColor: isDark ? Colors.white10 : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: statusColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F4BB9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Back Button
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2F4BB9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  String _formatFullDate(DateTime date) {
    final dayName = _getWeekdayName(date.weekday);
    return '$dayName, ${date.day} ${_getMonthName(date.month)} ${date.year}';
  }
}
