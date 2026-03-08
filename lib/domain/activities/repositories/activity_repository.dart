import '../../../data/models/activity_model.dart';

/// Repository contract for activity data operations
///
/// Defines the interface for all activity-related data access,
/// enabling abstraction from underlying data sources (Firestore, local storage, etc.)
abstract class ActivityRepository {
  /// Stream of all activities (real-time updates)
  ///
  /// Parameters:
  /// - [userId]: The user's unique identifier
  ///
  /// Returns: Real-time stream of [ActivityModel] list
  Stream<List<ActivityModel>> getActivitiesStream(String userId);

  /// Fetch all activities (one-time fetch)
  ///
  /// Parameters:
  /// - [userId]: The user's unique identifier
  ///
  /// Returns: List of [ActivityModel]
  /// Throws: Exception if data fetch fails
  Future<List<ActivityModel>> getActivities(String userId);

  /// Get a single activity by ID
  ///
  /// Parameters:
  /// - [userId]: The user's unique identifier
  /// - [activityId]: The activity's unique identifier
  ///
  /// Returns: [ActivityModel] if found, null otherwise
  /// Throws: Exception if fetch fails
  Future<ActivityModel?> getActivity(String userId, String activityId);

  /// Create a new activity
  ///
  /// Parameters:
  /// - [activity]: The activity data to create
  /// - [userId]: The user who is creating this activity
  ///
  /// Returns: The ID of the newly created activity
  /// Throws: Exception if creation fails
  Future<String> addActivity(ActivityModel activity, String userId);

  /// Update an existing activity
  ///
  /// Parameters:
  /// - [activityId]: The activity's unique identifier
  /// - [activity]: The updated activity data
  ///
  /// Throws: Exception if update fails
  Future<void> updateActivity(String activityId, ActivityModel activity);

  /// Delete an activity
  ///
  /// Parameters:
  /// - [activityId]: The activity's unique identifier
  ///
  /// Throws: Exception if deletion fails
  Future<void> deleteActivity(String activityId);

  /// Seed sample activities if none exist
  ///
  /// Used during onboarding or development.
  /// Parameters:
  /// - [userId]: The user's unique identifier
  ///
  /// Throws: Exception if seeding fails
  Future<void> seedSampleActivitiesIfEmpty(String userId);
}
