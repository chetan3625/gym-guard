class AttendanceModel {
  const AttendanceModel({
    required this.attendanceId,
    required this.userId,
    required this.gymId,
    required this.branchId,
    required this.checkIn,
    required this.checkOut,
    required this.totalTime,
    required this.date,
    required this.workoutSummary,
  });

  final String attendanceId;
  final String userId;
  final String gymId;
  final String branchId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String totalTime;
  final String date;
  final WorkoutSummaryModel? workoutSummary;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizePayload(json);
    return AttendanceModel(
      attendanceId:
          _readText(normalized, const ['attendance_id', 'attendanceId']) ?? '',
      userId: _readText(normalized, const ['user_id', 'userId']) ?? '',
      gymId: _readText(normalized, const ['gym_id', 'gymId']) ?? '',
      branchId: _readText(normalized, const ['branch_id', 'branchId']) ?? '',
      checkIn: _parseDate(normalized['check_in'] ?? normalized['checkIn']),
      checkOut: _parseDate(normalized['check_out'] ?? normalized['checkOut']),
      totalTime: _readText(normalized, const ['total_time', 'totalTime']) ?? '',
      date: _readText(normalized, const ['date']) ?? '',
      workoutSummary: normalized['workout_summary'] is Map
          ? WorkoutSummaryModel.fromJson(
              Map<String, dynamic>.from(normalized['workout_summary'] as Map),
            )
          : normalized['workoutSummary'] is Map
              ? WorkoutSummaryModel.fromJson(
                  Map<String, dynamic>.from(
                      normalized['workoutSummary'] as Map),
                )
              : null,
    );
  }

  static Map<String, dynamic> _normalizePayload(Map<String, dynamic> json) {
    if (json['data'] is Map) {
      return Map<String, dynamic>.from(json['data'] as Map);
    }
    if (json['attendance'] is Map) {
      return Map<String, dynamic>.from(json['attendance'] as Map);
    }
    return json;
  }
}

class WorkoutSummaryModel {
  const WorkoutSummaryModel({
    required this.logId,
    required this.memberId,
    required this.logDate,
    required this.notes,
    required this.totalExercises,
    required this.completedExercises,
    required this.exercises,
  });

  final String logId;
  final String memberId;
  final DateTime? logDate;
  final String notes;
  final int totalExercises;
  final int completedExercises;
  final List<WorkoutExerciseSummaryModel> exercises;

  factory WorkoutSummaryModel.fromJson(Map<String, dynamic> json) {
    final exercises = json['exercises'] is List
        ? (json['exercises'] as List)
            .whereType<Map>()
            .map(
              (item) => WorkoutExerciseSummaryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <WorkoutExerciseSummaryModel>[];

    return WorkoutSummaryModel(
      logId: _readText(json, const ['log_id', 'logId']) ?? '',
      memberId: _readText(json, const ['member_id', 'memberId']) ?? '',
      logDate: _parseDate(json['log_date'] ?? json['logDate']),
      notes: _readText(json, const ['notes']) ?? '',
      totalExercises:
          _parseInt(json['total_exercises'] ?? json['totalExercises']),
      completedExercises: _parseInt(
        json['completed_exercises'] ?? json['completedExercises'],
      ),
      exercises: exercises,
    );
  }
}

class WorkoutExerciseSummaryModel {
  const WorkoutExerciseSummaryModel({
    required this.trackingId,
    required this.isCompleted,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.completedAt,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseDescription,
    required this.bodyPartId,
    required this.bodyPartName,
    required this.categoryId,
    required this.categoryName,
  });

  final String trackingId;
  final bool isCompleted;
  final int setsCompleted;
  final String repsCompleted;
  final DateTime? completedAt;
  final String exerciseId;
  final String exerciseName;
  final String exerciseDescription;
  final String bodyPartId;
  final String bodyPartName;
  final String categoryId;
  final String categoryName;

  factory WorkoutExerciseSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseSummaryModel(
      trackingId: _readText(json, const ['tracking_id', 'trackingId']) ?? '',
      isCompleted: _parseBool(json['is_completed'] ?? json['isCompleted']),
      setsCompleted: _parseInt(json['sets_completed'] ?? json['setsCompleted']),
      repsCompleted:
          _readText(json, const ['reps_completed', 'repsCompleted']) ?? '',
      completedAt: _parseDate(json['completed_at'] ?? json['completedAt']),
      exerciseId: _readText(json, const ['exercise_id', 'exerciseId']) ?? '',
      exerciseName:
          _readText(json, const ['exercise_name', 'exerciseName']) ?? '',
      exerciseDescription: _readText(
            json,
            const ['exercise_description', 'exerciseDescription'],
          ) ??
          '',
      bodyPartId: _readText(json, const ['body_part_id', 'bodyPartId']) ?? '',
      bodyPartName:
          _readText(json, const ['body_part_name', 'bodyPartName']) ?? '',
      categoryId: _readText(json, const ['category_id', 'categoryId']) ?? '',
      categoryName:
          _readText(json, const ['category_name', 'categoryName']) ?? '',
    );
  }
}

String? _readText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  final raw = value?.toString().trim().toLowerCase() ?? '';
  return raw == 'true' || raw == '1' || raw == 'yes';
}
