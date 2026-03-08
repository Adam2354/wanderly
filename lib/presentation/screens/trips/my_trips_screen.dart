import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trip_provider.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/activity_model.dart';
import '../../providers/activity_provider.dart' hide categoriesProvider;
import 'package:intl/intl.dart';
import 'activity_detail_screen.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(filteredSortedTripsProvider);
    final filterStatus = ref.watch(tripFilterStatusProvider);
    final stats = ref.watch(tripStatsProvider);
    final activitiesAsync = ref.watch(activitiesProvider);
    final fallbackData = ref.watch(tripFallbackDataProvider);
    final fallbackStats = fallbackData.stats;
    final fallbackActivities = fallbackData.activities;

    final hasTripData = trips.isNotEmpty;
    final totalCount = hasTripData ? stats['total']! : fallbackStats['total']!;
    final upcomingCount = hasTripData
        ? stats['upcoming']!
        : fallbackStats['upcoming']!;
    final ongoingCount = hasTripData
        ? stats['ongoing']!
        : fallbackStats['ongoing']!;
    final completedCount = hasTripData
        ? stats['completed']!
        : fallbackStats['completed']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            tooltip: 'Trip Map',
            onPressed: () {
              Navigator.pushNamed(context, '/trip-map');
            },
            icon: const Icon(Icons.map_outlined),
          ),
          // Filter button
          PopupMenuButton<TripFilterStatus>(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).iconTheme.color,
            ),
            tooltip: 'Filter by Status',
            onSelected: (value) {
              ref.read(tripFilterStatusProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TripFilterStatus.all,
                child: Text('All Trips'),
              ),
              const PopupMenuItem(
                value: TripFilterStatus.upcoming,
                child: Text('Upcoming'),
              ),
              const PopupMenuItem(
                value: TripFilterStatus.ongoing,
                child: Text('Ongoing'),
              ),
              const PopupMenuItem(
                value: TripFilterStatus.completed,
                child: Text('Completed'),
              ),
            ],
          ),
          // Sort button
          PopupMenuButton<TripSortBy>(
            icon: Icon(Icons.sort, color: Theme.of(context).iconTheme.color),
            tooltip: 'Sort',
            onSelected: (value) {
              ref.read(tripSortByProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TripSortBy.dateDesc,
                child: Text('Date (Newest First)'),
              ),
              const PopupMenuItem(
                value: TripSortBy.dateAsc,
                child: Text('Date (Oldest First)'),
              ),
              const PopupMenuItem(
                value: TripSortBy.nameAsc,
                child: Text('Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: TripSortBy.nameDesc,
                child: Text('Name (Z-A)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    totalCount,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Upcoming',
                    upcomingCount,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Ongoing',
                    ongoingCount,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed',
                    completedCount,
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Active Filter Chip
          if (filterStatus != TripFilterStatus.all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text('Filter: ${_getFilterLabel(filterStatus)}'),
                onDeleted: () {
                  ref.read(tripFilterStatusProvider.notifier).state =
                      TripFilterStatus.all;
                },
              ),
            ),
          // Trips List
          Expanded(
            child: hasTripData
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      return _buildTripCard(context, ref, trips[index]);
                    },
                  )
                : activitiesAsync.isLoading && fallbackActivities.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : fallbackActivities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.luggage_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No trips found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start planning your next adventure!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: fallbackActivities.length,
                    itemBuilder: (context, index) {
                      return _buildActivityCard(
                        context,
                        fallbackActivities[index],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openTripFormDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Trip'),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, WidgetRef ref, TripModel trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    Color statusColor;
    IconData statusIcon;

    switch (trip.status) {
      case 'upcoming':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'ongoing':
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Trip Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: trip.imagePath != null
                    ? Image.asset(
                        trip.imagePath!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.location_on),
                      ),
              ),
              const SizedBox(width: 16),
              // Trip Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      trip.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date
                    if (trip.startDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              trip.endDate != null
                                  ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
                                  : dateFormat.format(trip.startDate!),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Status chip
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                trip.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            trip.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Trip Actions',
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _openTripFormDialog(context, ref, existingTrip: trip);
                      break;
                    case 'status_upcoming':
                      _updateTripStatus(context, ref, trip, 'upcoming');
                      break;
                    case 'status_ongoing':
                      _updateTripStatus(context, ref, trip, 'ongoing');
                      break;
                    case 'status_completed':
                      _updateTripStatus(context, ref, trip, 'completed');
                      break;
                    case 'delete':
                      _confirmDeleteTrip(context, ref, trip);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Trip'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'status_upcoming',
                    child: Text('Set as Upcoming'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status_ongoing',
                    child: Text('Set as Ongoing'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status_completed',
                    child: Text('Set as Completed'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Trip'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTripFormDialog(
    BuildContext context,
    WidgetRef ref, {
    TripModel? existingTrip,
  }) async {
    final isEdit = existingTrip != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: existingTrip?.name ?? '',
    );
    final locationController = TextEditingController(
      text: existingTrip?.location ?? '',
    );
    final notesController = TextEditingController(
      text: existingTrip?.notes ?? '',
    );
    final latitudeController = TextEditingController(
      text: existingTrip?.latitude?.toString() ?? '',
    );
    final longitudeController = TextEditingController(
      text: existingTrip?.longitude?.toString() ?? '',
    );

    final categories = ref.read(categoriesProvider);
    String selectedCategory = existingTrip?.category ?? categories.first;
    DateTime? selectedStartDate = existingTrip?.startDate;
    DateTime? selectedEndDate = existingTrip?.endDate;

    final dateFormat = DateFormat('MMM dd, yyyy');

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Trip' : 'Add Trip'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Trip Name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Trip name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Latitude (opsional)',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          final parsed = double.tryParse(text);
                          if (parsed == null || parsed < -90 || parsed > 90) {
                            return 'Latitude harus antara -90 hingga 90';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Longitude (opsional)',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          final parsed = double.tryParse(text);
                          if (parsed == null || parsed < -180 || parsed > 180) {
                            return 'Longitude harus antara -180 hingga 180';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Start Date'),
                        subtitle: Text(
                          selectedStartDate != null
                              ? dateFormat.format(selectedStartDate!)
                              : 'Not set',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedStartDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedStartDate = pickedDate;
                                if (selectedEndDate != null &&
                                    selectedEndDate!.isBefore(pickedDate)) {
                                  selectedEndDate = pickedDate;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('End Date'),
                        subtitle: Text(
                          selectedEndDate != null
                              ? dateFormat.format(selectedEndDate!)
                              : 'Not set',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final initialDate =
                                selectedEndDate ??
                                selectedStartDate ??
                                DateTime.now();
                            final firstDate =
                                selectedStartDate ?? DateTime(2000);
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: initialDate,
                              firstDate: firstDate,
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedEndDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }

                    final trip = TripModel(
                      id: existingTrip?.id,
                      name: nameController.text.trim(),
                      location: locationController.text.trim(),
                      notes: notesController.text.trim(),
                      category: selectedCategory,
                      userId: existingTrip?.userId ?? '',
                      startDate: selectedStartDate,
                      endDate: selectedEndDate,
                      imagePath: existingTrip?.imagePath,
                      status: existingTrip?.status ?? 'upcoming',
                      createdAt: existingTrip?.createdAt,
                      latitude: latitudeController.text.trim().isEmpty
                          ? null
                          : double.tryParse(latitudeController.text.trim()),
                      longitude: longitudeController.text.trim().isEmpty
                          ? null
                          : double.tryParse(longitudeController.text.trim()),
                    );

                    if (isEdit && existingTrip.id != null) {
                      await _runTripAction(
                        context,
                        ref,
                        action: () => ref
                            .read(tripNotifierProvider.notifier)
                            .updateTrip(existingTrip.id!, trip),
                        successMessage: 'Trip updated',
                      );
                    } else {
                      await _runTripAction(
                        context,
                        ref,
                        action: () => ref
                            .read(tripNotifierProvider.notifier)
                            .addTrip(trip),
                        successMessage: 'Trip added',
                      );
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: Text(isEdit ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    locationController.dispose();
    notesController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    if (submitted == true && context.mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _confirmDeleteTrip(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
  ) async {
    if (trip.id == null) {
      _showSnackBar(context, 'Trip tidak valid untuk dihapus');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: Text('Hapus trip "${trip.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await _runTripAction(
      context,
      ref,
      action: () =>
          ref.read(tripNotifierProvider.notifier).deleteTrip(trip.id!),
      successMessage: 'Trip deleted',
    );
  }

  Future<void> _updateTripStatus(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
    String status,
  ) async {
    if (trip.id == null) {
      _showSnackBar(context, 'Trip tidak valid untuk diupdate');
      return;
    }

    await _runTripAction(
      context,
      ref,
      action: () => ref
          .read(tripNotifierProvider.notifier)
          .updateTripStatus(trip.id!, status),
      successMessage: 'Status trip diperbarui',
    );
  }

  Future<void> _runTripAction(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    await action();
    final actionState = ref.read(tripNotifierProvider);

    if (!context.mounted) {
      return;
    }

    if (actionState.hasError) {
      _showSnackBar(
        context,
        'Gagal menyimpan ke Firestore: ${actionState.error}',
      );
      return;
    }

    _showSnackBar(context, successMessage);
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final activityStatus = getActivityStatus(activity, DateTime.now());
    final status = switch (activityStatus) {
      ActivityStatus.upcoming => 'upcoming',
      ActivityStatus.ongoing => 'ongoing',
      ActivityStatus.completed => 'completed',
    };
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'upcoming':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'ongoing':
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(activity: activity),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: activity.imagePath != null
                    ? (activity.imagePath!.startsWith('assets/')
                          ? Image.asset(
                              activity.imagePath!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            )
                          : Image.file(
                              File(activity.imagePath!),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ))
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.location_on),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (activity.date != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dateFormat.format(activity.date!),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activity.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
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
  }

  String _getFilterLabel(TripFilterStatus status) {
    switch (status) {
      case TripFilterStatus.upcoming:
        return 'Upcoming';
      case TripFilterStatus.ongoing:
        return 'Ongoing';
      case TripFilterStatus.completed:
        return 'Completed';
      default:
        return 'All';
    }
  }
}
