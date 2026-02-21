import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/trip_provider.dart';
import '../../data/models/trip_model.dart';
import 'package:intl/intl.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(filteredSortedTripsProvider);
    final filterStatus = ref.watch(tripFilterStatusProvider);
    final stats = ref.watch(tripStatsProvider);

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
                _buildStatItem(context, 'Total', stats['total']!, Colors.blue),
                _buildStatItem(
                  context,
                  'Upcoming',
                  stats['upcoming']!,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Ongoing',
                  stats['ongoing']!,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Completed',
                  stats['completed']!,
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
            child: trips.isEmpty
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
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      return _buildTripCard(context, trips[index]);
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
