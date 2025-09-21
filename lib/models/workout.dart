import 'package:json_annotation/json_annotation.dart';
import 'exercise.dart';

part 'workout.g.dart';

@JsonSerializable()
class Workout {
  final String id;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final int estimatedDuration; // in minutes
  final String difficulty;
  final List<String> tags;
  final DateTime? lastPerformed;
  final int timesPerformed;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.estimatedDuration,
    required this.difficulty,
    required this.tags,
    this.lastPerformed,
    this.timesPerformed = 0,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    int? estimatedDuration,
    String? difficulty,
    List<String>? tags,
    DateTime? lastPerformed,
    int? timesPerformed,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      timesPerformed: timesPerformed ?? this.timesPerformed,
    );
  }
}

@JsonSerializable()
class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final List<String> workoutIds;
  final List<Workout> workouts;
  final int daysPerWeek;
  final String planType; // push/pull/legs, upper/lower, full body, etc.
  final bool isPredefined;
  final DateTime createdAt;
  final DateTime? lastModified;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.workoutIds,
    required this.workouts,
    required this.daysPerWeek,
    required this.planType,
    this.isPredefined = false,
    required this.createdAt,
    this.lastModified,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? workoutIds,
    List<Workout>? workouts,
    int? daysPerWeek,
    String? planType,
    bool? isPredefined,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      workoutIds: workoutIds ?? this.workoutIds,
      workouts: workouts ?? this.workouts,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      planType: planType ?? this.planType,
      isPredefined: isPredefined ?? this.isPredefined,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}