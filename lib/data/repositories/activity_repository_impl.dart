import '../../domain/activities/repositories/activity_repository.dart';
import '../datasources/firebase/activity_firestore_datasource.dart';
import '../models/activity_model.dart';

/// Implementation of [ActivityRepository] using Firestore as data source.
class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityFirestoreDatasource _activityService;

  ActivityRepositoryImpl(this._activityService);

  @override
  Stream<List<ActivityModel>> getActivitiesStream(String userId) {
    return _activityService.getActivitiesStream(userId);
  }

  @override
  Future<List<ActivityModel>> getActivities(String userId) async {
    // Get current activities from stream (take first element)
    return _activityService.getActivitiesStream(userId).first;
  }

  @override
  Future<ActivityModel?> getActivity(String userId, String activityId) async {
    final activities = await getActivities(userId);
    try {
      return activities.firstWhere((activity) => activity.id == activityId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> addActivity(ActivityModel activity, String userId) {
    return _activityService.addActivity(activity, userId);
  }

  @override
  Future<void> updateActivity(String activityId, ActivityModel activity) {
    return _activityService.updateActivity(activityId, activity);
  }

  @override
  Future<void> deleteActivity(String activityId) {
    return _activityService.deleteActivity(activityId);
  }

  @override
  Future<void> seedSampleActivitiesIfEmpty(String userId) {
    return _activityService.seedSampleActivitiesIfEmpty(userId);
  }
}
