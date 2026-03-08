import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/activity_status_formatter.dart';

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

  Future<void> _updateStatus(ActivityStatus status) async {
    final dateForStatus = ActivityStatusFormatter.getDateForStatus(status);
    final updated = _activity.copyWith(date: dateForStatus);

    if (_activity.id != null) {
      await ref
          .read(activitiesProvider.notifier)
          .updateActivity(_activity.id!, updated);
    }

    setState(() {
      _activity = updated;
    });
  }

  Future<void> _launchGoogleMaps(BuildContext context, String mapsUri) async {
    if (mapsUri.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi wisata belum tersedia.')),
      );
      return;
    }

    final uri = Uri.parse(mapsUri);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps.')),
      );
    }
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
    final cardColor = Theme.of(context).cardColor;
    final status = getActivityStatus(_activity, DateTime.now());
    final statusColor = ActivityStatusFormatter.getStatusColor(status);
    final detailDescription = _activity.notes.trim().isNotEmpty
        ? '${_activity.notes.trim()}\n\nKamu bisa melengkapi rute terbaik, estimasi waktu kunjungan, dan rekomendasi spot foto favorit agar perjalanan lebih terarah. Tambahkan juga catatan akses transportasi, titik meeting, serta alternatif urutan kunjungan supaya itinerary tetap fleksibel ketika kondisi di lapangan berubah.\n\nAgar pengalaman makin optimal, pertimbangkan jam kunjungan yang lebih sepi, siapkan waktu istirahat singkat di tengah aktivitas, dan catat hal penting setelah kunjungan selesai sebagai referensi untuk perjalanan berikutnya.'
        : 'Belum ada catatan detail untuk aktivitas ini. Tambahkan informasi penting seperti durasi kunjungan, rekomendasi waktu terbaik, serta tips singkat agar perjalananmu lebih nyaman.\n\nKamu juga bisa menulis rencana transportasi, estimasi biaya tambahan, dan opsi cadangan bila cuaca berubah agar aktivitas tetap berjalan lancar.\n\nSetelah selesai, simpan highlight perjalanan, spot favorit, dan insight kecil lainnya supaya itinerary berikutnya bisa disusun lebih cepat dan akurat.';

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
                                  ActivityStatusFormatter.getStatusLabel(
                                    status,
                                  ),
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 21,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _activity.location,
                                      style: TextStyle(
                                        fontSize: 15,
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
                                    size: 21,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _activity.date != null
                                          ? _formatFullDate(_activity.date!)
                                          : 'Belum dijadwalkan',
                                      style: TextStyle(
                                        fontSize: 15,
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
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final mapsUri = await ref.read(
                              googleMapsUriProvider((
                                destinationName: _activity.name,
                                location: _activity.location,
                                activity: _activity,
                              )).future,
                            );
                            if (mounted) {
                              await _launchGoogleMaps(context, mapsUri);
                            }
                          },
                          icon: const Icon(Icons.map_outlined, size: 19),
                          label: const Text(
                            'Lihat google maps',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F4BB9),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                        detailDescription,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color.fromARGB(255, 26, 26, 26),
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
                                  child: Text(
                                    ActivityStatusFormatter.getStatusLabel(
                                      value,
                                    ),
                                  ),
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
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F4BB9),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

                // Footer
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo_wanderly.png',
                        height: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enjoy your trip with glorious serve from harisenin.com!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jl. Raya Pajajaran No.88, Kel. Tanah Sareal, Kec. Bogor\nTengah, Kota Bogor, Jawa Barat, 16167, Indonesia',
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+62-891827-23293',
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                      const SizedBox(height: 12),
                      Image.asset('assets/images/Sosmed.png', height: 32),
                      const SizedBox(height: 12),
                      Text(
                        '©2026 Khoiri Rizki Bani Adam, All Rights Reserved',
                        style: TextStyle(
                          fontSize: 10,
                          color: subTextColor.withOpacity(0.7),
                        ),
                      ),
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
