import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/trip_provider.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/activity_model.dart';
import '../../data/providers/activity_provider.dart';
import 'package:intl/intl.dart';
import 'activity_detail_screen.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(filteredSortedTripsProvider);
    final filterStatus = ref.watch(tripFilterStatusProvider);
    final sortBy = ref.watch(tripSortByProvider);
    final stats = ref.watch(tripStatsProvider);
    final activitiesAsync = ref.watch(activitiesProvider);

    final allActivities = activitiesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <ActivityModel>[],
    );
    final fallbackStats = _buildActivityStats(allActivities);
    final fallbackActivities = _filterAndSortActivities(
      allActivities,
      filterStatus,
      sortBy,
    );

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
                _buildStatItem(context, 'Total', totalCount, Colors.blue),
                _buildStatItem(
                  context,
                  'Upcoming',
                  upcomingCount,
                  Colors.orange,
                ),
                _buildStatItem(context, 'Ongoing', ongoingCount, Colors.green),
                _buildStatItem(
                  context,
                  'Completed',
                  completedCount,
                  Colors.grey,
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
                      return _buildTripCard(context, trips[index]);
                    },
                  )
                : activitiesAsync.isLoading && allActivities.isEmpty
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
          // Navigate to add trip screen
          Navigator.pushNamed(context, '/add_trip');
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
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
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
          // Navigate to trip detail
          Navigator.pushNamed(context, '/trip_detail', arguments: trip);
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
                          Text(
                            trip.endDate != null
                                ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
                                : dateFormat.format(trip.startDate!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Status chip
                    Row(
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
                        const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final status = _activityStatusString(activity);
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
                          Text(
                            dateFormat.format(activity.date!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
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
                        const SizedBox(width: 8),
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

  String _activityStatusString(ActivityModel activity) {
    final status = getActivityStatus(activity, DateTime.now());
    switch (status) {
      case ActivityStatus.upcoming:
        return 'upcoming';
      case ActivityStatus.ongoing:
        return 'ongoing';
      case ActivityStatus.completed:
        return 'completed';
    }
  }

  Map<String, int> _buildActivityStats(List<ActivityModel> activities) {
    int upcoming = 0;
    int ongoing = 0;
    int completed = 0;

    for (final activity in activities) {
      switch (_activityStatusString(activity)) {
        case 'upcoming':
          upcoming++;
          break;
        case 'ongoing':
          ongoing++;
          break;
        case 'completed':
          completed++;
          break;
      }
    }

    return {
      'total': activities.length,
      'upcoming': upcoming,
      'ongoing': ongoing,
      'completed': completed,
    };
  }

  List<ActivityModel> _filterAndSortActivities(
    List<ActivityModel> activities,
    TripFilterStatus filterStatus,
    TripSortBy sortBy,
  ) {
    var filtered = activities.where((activity) {
      final status = _activityStatusString(activity);
      switch (filterStatus) {
        case TripFilterStatus.upcoming:
          return status == 'upcoming';
        case TripFilterStatus.ongoing:
          return status == 'ongoing';
        case TripFilterStatus.completed:
          return status == 'completed';
        case TripFilterStatus.all:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      switch (sortBy) {
        case TripSortBy.dateAsc:
          final aDate = a.date ?? DateTime(9999);
          final bDate = b.date ?? DateTime(9999);
          return aDate.compareTo(bDate);
        case TripSortBy.dateDesc:
          final aDate = a.date ?? DateTime(0);
          final bDate = b.date ?? DateTime(0);
          return bDate.compareTo(aDate);
        case TripSortBy.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case TripSortBy.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });

    return filtered;
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
