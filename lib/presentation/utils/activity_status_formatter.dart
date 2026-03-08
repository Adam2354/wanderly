/// Formatting utilities for activity status display in UI
///
/// Provides consistent status label text and color coding across screens

import 'package:flutter/material.dart';

import '../providers/activity_provider.dart';

/// Formats activity status for UI display
///
/// Provides human-readable labels and color coding for status states
class ActivityStatusFormatter {
  /// Gets display label for activity status
  ///
  /// Returns:
  /// - "Upcoming" for future activities
  /// - "Ongoing" for current activities
  /// - "Completed" for past activities
  static String getStatusLabel(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return 'Upcoming';
      case ActivityStatus.ongoing:
        return 'Ongoing';
      case ActivityStatus.completed:
        return 'Completed';
    }
  }

  /// Gets color for activity status badge/display
  ///
  /// Returns:
  /// - Amber (#F59E0B) for upcoming
  /// - Blue (#2F4BB9) for ongoing
  /// - Green (#10B981) for completed
  static Color getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return const Color(0xFFF59E0B);
      case ActivityStatus.ongoing:
        return const Color(0xFF2F4BB9);
      case ActivityStatus.completed:
        return const Color(0xFF10B981);
    }
  }

  /// Converts status to a test date for Firestore updates
  ///
  /// Used when updating activity status - sets date to reflect the status:
  /// - Completed: yesterday
  /// - Ongoing: today
  /// - Upcoming: tomorrow
  static DateTime getDateForStatus(ActivityStatus status) {
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
}
