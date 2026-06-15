class WorkoutCategoryModel {
  const WorkoutCategoryModel({
    required this.categoryId,
    required this.name,
    required this.description,
    this.createdAt,
  });

  final String categoryId;
  final String name;
  final String description;
  final DateTime? createdAt;

  factory WorkoutCategoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutCategoryModel(
      categoryId: _readString(json, const ['category_id', 'categoryId']),
      name: _readString(json, const ['name']),
      description: _readString(json, const ['description']),
      createdAt: _readDateTime(json, const ['created_at', 'createdAt']),
    );
  }
}

class WorkoutBodyPartModel {
  const WorkoutBodyPartModel({
    required this.bodyPartId,
    required this.name,
    required this.categoryId,
  });

  final String bodyPartId;
  final String name;
  final String categoryId;

  factory WorkoutBodyPartModel.fromJson(Map<String, dynamic> json) {
    return WorkoutBodyPartModel(
      bodyPartId: _readString(json, const ['body_part_id', 'bodyPartId']),
      name: _readString(json, const ['name']),
      categoryId: _readString(json, const ['category_id', 'categoryId']),
    );
  }
}

class WorkoutExerciseModel {
  const WorkoutExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.bodyPartId,
    required this.description,
    required this.mediaUrl,
    required this.defaultReps,
    required this.defaultSets,
    this.createdOn,
  });

  final String exerciseId;
  final String name;
  final String bodyPartId;
  final String description;
  final String mediaUrl;
  final int defaultReps;
  final int defaultSets;
  final DateTime? createdOn;

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      exerciseId: _readString(json, const ['exercise_id', 'exerciseId']),
      name: _readString(json, const ['name']),
      bodyPartId: _readString(json, const ['body_part_id', 'bodyPartId']),
      description: _readString(json, const ['description']),
      mediaUrl: _readString(json, const ['media_url', 'mediaUrl']),
      defaultReps: _readInt(json, const ['default_reps', 'defaultReps']),
      defaultSets: _readInt(json, const ['default_sets', 'defaultSets']),
      createdOn: _readDateTime(json, const ['created_on', 'createdOn']),
    );
  }
}

class WorkoutTrackingModel {
  const WorkoutTrackingModel({
    required this.trackingId,
    required this.logId,
    required this.exerciseId,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.isCompleted,
    this.createdOn,
  });

  final String trackingId;
  final String logId;
  final String exerciseId;
  final int setsCompleted;
  final String repsCompleted;
  final bool isCompleted;
  final DateTime? createdOn;

  factory WorkoutTrackingModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTrackingModel(
      trackingId: _readString(json, const ['tracking_id', 'trackingId']),
      logId: _readString(json, const ['log_id', 'logId']),
      exerciseId: _readString(json, const ['exercise_id', 'exerciseId']),
      setsCompleted: _readInt(json, const ['sets_completed', 'setsCompleted']),
      repsCompleted: _readString(json, const ['reps_completed', 'repsCompleted']),
      isCompleted: json['is_completed'] == true || json['isCompleted'] == true,
      createdOn: _readDateTime(json, const ['created_on', 'createdOn']),
    );
  }
}

class WorkoutLogExerciseModel {
  const WorkoutLogExerciseModel({
    required this.trackingId,
    required this.isCompleted,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseDescription,
    required this.bodyPartId,
    required this.bodyPartName,
    required this.categoryId,
    required this.categoryName,
    this.completedAt,
  });

  final String trackingId;
  final bool isCompleted;
  final int setsCompleted;
  final String repsCompleted;
  final String exerciseId;
  final String exerciseName;
  final String exerciseDescription;
  final String bodyPartId;
  final String bodyPartName;
  final String categoryId;
  final String categoryName;
  final DateTime? completedAt;

  factory WorkoutLogExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogExerciseModel(
      trackingId: _readString(json, const ['tracking_id', 'trackingId']),
      isCompleted: json['is_completed'] == true || json['isCompleted'] == true,
      setsCompleted: _readInt(json, const ['sets_completed', 'setsCompleted']),
      repsCompleted: _readString(json, const ['reps_completed', 'repsCompleted']),
      exerciseId: _readString(json, const ['exercise_id', 'exerciseId']),
      exerciseName: _readString(json, const ['exercise_name', 'exerciseName']),
      exerciseDescription: _readString(
        json,
        const ['exercise_description', 'exerciseDescription'],
      ),
      bodyPartId: _readString(json, const ['body_part_id', 'bodyPartId']),
      bodyPartName: _readString(json, const ['body_part_name', 'bodyPartName']),
      categoryId: _readString(json, const ['category_id', 'categoryId']),
      categoryName: _readString(json, const ['category_name', 'categoryName']),
      completedAt: _readDateTime(json, const ['completed_at', 'completedAt']),
    );
  }
}

class WorkoutLogModel {
  const WorkoutLogModel({
    required this.logId,
    required this.memberId,
    required this.notes,
    required this.totalExercises,
    required this.completedExercises,
    required this.exercises,
    this.logDate,
  });

  final String logId;
  final String memberId;
  final DateTime? logDate;
  final String notes;
  final int totalExercises;
  final int completedExercises;
  final List<WorkoutLogExerciseModel> exercises;

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'];
    return WorkoutLogModel(
      logId: _readString(json, const ['log_id', 'logId']),
      memberId: _readString(json, const ['member_id', 'memberId']),
      logDate: _readDateTime(json, const ['log_date', 'logDate']),
      notes: _readString(json, const ['notes']),
      totalExercises: _readInt(json, const ['total_exercises', 'totalExercises']),
      completedExercises:
          _readInt(json, const ['completed_exercises', 'completedExercises']),
      exercises: rawExercises is List
          ? rawExercises
              .whereType<Map>()
              .map((item) => WorkoutLogExerciseModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const <WorkoutLogExerciseModel>[],
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    return value.toString();
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime? _readDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
  }
  return null;
}
