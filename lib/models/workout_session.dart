import 'package:json_annotation/json_annotation.dart';

part 'workout_session.g.dart';

@JsonSerializable()
class WorkoutSession {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in minutes
  final bool completed;
  final String notes;
  final List<SessionExercise> exercises;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.completed = false,
    this.notes = '',
    required this.exercises,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    bool? completed,
    String? notes,
    List<SessionExercise>? exercises,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
    );
  }
}

@JsonSerializable()
class SessionExercise {
  final String exerciseId;
  final String exerciseName;
  final List<SessionSet> sets;

  SessionExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) => _$SessionExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$SessionExerciseToJson(this);
}

@JsonSerializable()
class SessionSet {
  final int reps;
  final double weight;
  final int duration;
  final bool completed;
  final DateTime timestamp;

  SessionSet({
    required this.reps,
    required this.weight,
    this.duration = 0,
    this.completed = false,
    required this.timestamp,
  });

  factory SessionSet.fromJson(Map<String, dynamic> json) => _$SessionSetFromJson(json);
  Map<String, dynamic> toJson() => _$SessionSetToJson(this);
}