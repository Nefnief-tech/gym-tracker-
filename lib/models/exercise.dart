import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final String muscleGroup;
  final String equipment;
  final String instructions;
  final List<String> images;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
    required this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class ExerciseSet {
  final int reps;
  final double weight;
  final int duration; // in seconds
  final bool completed;

  ExerciseSet({
    required this.reps,
    required this.weight,
    this.duration = 0,
    this.completed = false,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$ExerciseSetFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  ExerciseSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    bool? completed,
  }) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }
}

@JsonSerializable()
class WorkoutExercise {
  final String exerciseId;
  final Exercise exercise;
  final List<ExerciseSet> sets;
  final int restTime; // in seconds
  final String notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exercise,
    required this.sets,
    this.restTime = 60,
    this.notes = '',
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutExerciseToJson(this);

  WorkoutExercise copyWith({
    String? exerciseId,
    Exercise? exercise,
    List<ExerciseSet>? sets,
    int? restTime,
    String? notes,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
    );
  }
}