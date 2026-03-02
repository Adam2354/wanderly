import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/activity_model.dart';
import '../../data/providers/activity_provider.dart';
import '../trips/activity_detail_screen.dart';

class MyItineraryScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const MyItineraryScreen({super.key, this.initialCategory});

  @override
  ConsumerState<MyItineraryScreen> createState() => _MyItineraryScreenState();
}

class _MyItineraryScreenState extends ConsumerState<MyItineraryScreen> {
  late String selectedCategory;

  String _filterLabel(ActivityFilter filter) {
    switch (filter) {
      case ActivityFilter.upcoming:
        return 'Upcoming';
      case ActivityFilter.ongoing:
        return 'Ongoing';
      case ActivityFilter.completed:
        return 'Completed';
      case ActivityFilter.all:
        return 'Semua';
    }
  }

  String _sortLabel(ActivitySort sort) {
    switch (sort) {
      case ActivitySort.startDateDesc:
        return 'Tanggal Terbaru';
      case ActivitySort.startDateAsc:
        return 'Tanggal Terdekat';
    }
  }

  String _statusLabel(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.ongoing:
        return 'Ongoing';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.upcoming:
        return 'Upcoming';
    }
  }

  Color _statusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.ongoing:
        return const Color(0xFFF59E0B); // amber
      case ActivityStatus.completed:
        return const Color(0xFF10B981); // green
      case ActivityStatus.upcoming:
        return const Color(0xFF2F4BB9); // blue
    }
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = 'Sightseeing';
    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }
  }

  void _showActivityForm(BuildContext context, {ActivityModel? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final locationController = TextEditingController(
      text: existing?.location ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    DateTime? selectedDate = existing?.date;
    String? selectedImagePath = existing?.imagePath;
    final imagePicker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor =
              Theme.of(context).textTheme.bodyLarge?.color ??
              (isDark ? Colors.white : Colors.black);
          final subTextColor =
              Theme.of(context).textTheme.bodySmall?.color ??
              (isDark ? Colors.white70 : Colors.black54);
          final cardColor = Theme.of(context).cardColor;
          final inputFill = isDark ? Colors.white10 : Colors.white;

          Widget imagePreview() {
            if (selectedImagePath == null || selectedImagePath!.isEmpty) {
              return Container(
                height: 140,
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Belum ada gambar',
                    style: TextStyle(color: subTextColor),
                  ),
                ),
              );
            }

            final path = selectedImagePath!;
            final isAsset = path.startsWith('assets/');
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: isAsset
                    ? Image.asset(path, fit: BoxFit.cover)
                    : Image.file(File(path), fit: BoxFit.cover),
              ),
            );
          }

          return Dialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing != null ? 'Edit Wisata' : 'Tambah Wisata',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Nama wisata',
                          labelStyle: TextStyle(color: subTextColor),
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locationController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Lokasi',
                          labelStyle: TextStyle(color: subTextColor),
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Catatan (opsional)',
                          labelStyle: TextStyle(color: subTextColor),
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal kunjungan (opsional)',
                            labelStyle: TextStyle(color: subTextColor),
                            filled: true,
                            fillColor: inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: subTextColor,
                            ),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Pilih tanggal',
                            style: TextStyle(
                              color: selectedDate != null
                                  ? textColor
                                  : subTextColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Gambar (opsional)',
                        style: TextStyle(fontSize: 12, color: subTextColor),
                      ),
                      const SizedBox(height: 8),
                      imagePreview(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await imagePicker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85,
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    selectedImagePath = picked.path;
                                  });
                                }
                              },
                              icon: Icon(Icons.photo, color: textColor),
                              label: Text(
                                'Pilih Gambar',
                                style: TextStyle(color: textColor),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (selectedImagePath != null)
                            OutlinedButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  selectedImagePath = null;
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final name = nameController.text.trim();
                              if (name.isEmpty) return;

                              final location = locationController.text.trim();
                              final notes = notesController.text.trim();

                              final activity = ActivityModel(
                                name: name,
                                location: location,
                                notes: notes,
                                date: selectedDate,
                                imagePath:
                                    selectedImagePath ?? existing?.imagePath,
                                category: selectedCategory,
                              );

                              if (existing != null) {
                                if (existing.id != null) {
                                  ref
                                      .read(activitiesProvider.notifier)
                                      .updateActivity(existing.id!, activity);
                                }
                              } else {
                                ref
                                    .read(activitiesProvider.notifier)
                                    .addActivity(activity);
                              }

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F4BB9),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteItem(BuildContext context, ActivityModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Wisata'),
        content: const Text('Yakin ingin menghapus wisata ini dari itinerary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (item.id != null) {
                ref.read(activitiesProvider.notifier).deleteActivity(item.id!);
              }
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final activitiesAsync = ref.watch(activitiesProvider);
    final sortOrder = ref.watch(activitySortProvider);
    final statusFilter = ref.watch(activityFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: activitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(activitiesProvider.notifier).refreshActivities();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (allActivities) {
            var activities = allActivities
                .where((activity) => activity.category == selectedCategory)
                .toList();
            final now = DateTime.now();

            activities = activities.where((activity) {
              final status = getActivityStatus(activity, now);
              switch (statusFilter) {
                case ActivityFilter.upcoming:
                  return status == ActivityStatus.upcoming;
                case ActivityFilter.ongoing:
                  return status == ActivityStatus.ongoing;
                case ActivityFilter.completed:
                  return status == ActivityStatus.completed;
                case ActivityFilter.all:
                  return true;
              }
            }).toList();

            activities.sort((a, b) {
              final aDate =
                  a.date ??
                  (sortOrder == ActivitySort.startDateAsc
                      ? DateTime(9999)
                      : DateTime(0));
              final bDate =
                  b.date ??
                  (sortOrder == ActivitySort.startDateAsc
                      ? DateTime(9999)
                      : DateTime(0));
              return sortOrder == ActivitySort.startDateAsc
                  ? aDate.compareTo(bDate)
                  : bDate.compareTo(aDate);
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: textColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Wisata Saya',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'Kategori: $selectedCategory',
                        style: TextStyle(fontSize: 16, color: subTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: Icon(Icons.expand_more, color: textColor),
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor, fontSize: 14),
                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<ActivityFilter>(
                            value: statusFilter,
                            underline: const SizedBox(),
                            isExpanded: true,
                            icon: Icon(Icons.tune, color: textColor),
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor, fontSize: 14),
                            items: ActivityFilter.values
                                .map(
                                  (filter) => DropdownMenuItem(
                                    value: filter,
                                    child: Text(_filterLabel(filter)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              ref.read(activityFilterProvider.notifier).state =
                                  value;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<ActivitySort>(
                            value: sortOrder,
                            underline: const SizedBox(),
                            isExpanded: true,
                            icon: Icon(Icons.sort, color: textColor),
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor, fontSize: 14),
                            items: ActivitySort.values
                                .map(
                                  (sort) => DropdownMenuItem(
                                    value: sort,
                                    child: Text(_sortLabel(sort)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              ref.read(activitySortProvider.notifier).state =
                                  value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: activities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: subTextColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada wisata di kategori ini',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          itemCount: activities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = activities[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ActivityDetailScreen(activity: item),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.4)
                                          : Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: item.imagePath != null
                                            ? (item.imagePath!.startsWith(
                                                    'assets/',
                                                  )
                                                  ? Image.asset(
                                                      item.imagePath!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: Colors
                                                                  .grey[300],
                                                              child: const Icon(
                                                                Icons.image,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                    )
                                                  : Image.file(
                                                      File(item.imagePath!),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: Colors
                                                                  .grey[300],
                                                              child: const Icon(
                                                                Icons.image,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                    ))
                                            : Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: [
                                                    _buildChip(
                                                      item.category,
                                                      const Color(0xFF2F4BB9),
                                                    ),
                                                    _buildChip(
                                                      _statusLabel(
                                                        getActivityStatus(
                                                          item,
                                                          now,
                                                        ),
                                                      ),
                                                      _statusColor(
                                                        getActivityStatus(
                                                          item,
                                                          now,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Date
                                            if (item.date != null)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                    color: subTextColor,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${item.date!.day}/${item.date!.month}/${item.date!.year}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: subTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (item.date != null)
                                              const SizedBox(height: 8),

                                            if (item.location.isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: subTextColor,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      item.location,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: subTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (item.location.isNotEmpty)
                                              const SizedBox(height: 8),

                                            if (item.notes.isNotEmpty)
                                              Text(
                                                item.notes,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: subTextColor,
                                                  height: 1.5,
                                                ),
                                              ),
                                            if (item.notes.isNotEmpty)
                                              const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 46,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () =>
                                                          _showActivityForm(
                                                            context,
                                                            existing: item,
                                                          ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFF2F4BB9,
                                                            ),
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 10,
                                                            ),
                                                        minimumSize: const Size(
                                                          0,
                                                          46,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .standard,
                                                      ),
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      label: const Text(
                                                        'Edit',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 46,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () =>
                                                          _deleteItem(
                                                            context,
                                                            item,
                                                          ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 10,
                                                            ),
                                                        minimumSize: const Size(
                                                          0,
                                                          46,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .standard,
                                                      ),
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      label: const Text(
                                                        'Hapus',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
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
                            );
                          },
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _showActivityForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4BB9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tambah Wisata',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
