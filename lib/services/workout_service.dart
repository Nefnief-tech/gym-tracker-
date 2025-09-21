import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import 'database_service.dart';

class WorkoutService extends ChangeNotifier {
  final DatabaseService _databaseService;
  
  List<Exercise> _exercises = [];
  List<Workout> _workouts = [];
  List<WorkoutPlan> _workoutPlans = [];
  List<WorkoutSession> _workoutSessions = [];
  
  WorkoutSession? _currentSession;
  
  WorkoutService(this._databaseService);

  // Getters
  List<Exercise> get exercises => _exercises;
  List<Workout> get workouts => _workouts;
  List<WorkoutPlan> get workoutPlans => _workoutPlans;
  List<WorkoutSession> get workoutSessions => _workoutSessions;
  WorkoutSession? get currentSession => _currentSession;

  // Initialize service
  Future<void> initialize() async {
    await _loadExercises();
    await _loadWorkouts();
    await _loadWorkoutPlans();
    await _loadWorkoutSessions();
    await _loadPredefinedPlans();
  }

  // Load exercises
  Future<void> _loadExercises() async {
    _exercises = await _databaseService.getAllExercises();
    if (_exercises.isEmpty) {
      await _loadDefaultExercises();
    }
    notifyListeners();
  }

  // Load workouts
  Future<void> _loadWorkouts() async {
    _workouts = await _databaseService.getAllWorkouts();
    notifyListeners();
  }

  // Load workout plans
  Future<void> _loadWorkoutPlans() async {
    _workoutPlans = await _databaseService.getAllWorkoutPlans();
    notifyListeners();
  }

  // Load workout sessions
  Future<void> _loadWorkoutSessions() async {
    _workoutSessions = await _databaseService.getAllWorkoutSessions();
    notifyListeners();
  }

  // Load default exercises
  Future<void> _loadDefaultExercises() async {
    final defaultExercises = [
      Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        description: 'Classic chest exercise using a barbell',
        category: 'strength',
        muscleGroup: 'chest',
        equipment: 'barbell',
        instructions: 'Lie on bench, grip barbell, lower to chest, press up',
        images: [],
      ),
      Exercise(
        id: 'squat',
        name: 'Squat',
        description: 'Fundamental leg exercise',
        category: 'strength',
        muscleGroup: 'legs',
        equipment: 'barbell',
        instructions: 'Stand with feet shoulder-width apart, squat down, stand up',
        images: [],
      ),
      Exercise(
        id: 'deadlift',
        name: 'Deadlift',
        description: 'Full body compound exercise',
        category: 'strength',
        muscleGroup: 'back',
        equipment: 'barbell',
        instructions: 'Bend at hips and knees, lift bar, stand tall',
        images: [],
      ),
      Exercise(
        id: 'pull_up',
        name: 'Pull-up',
        description: 'Upper body pulling exercise',
        category: 'strength',
        muscleGroup: 'back',
        equipment: 'pull_up_bar',
        instructions: 'Hang from bar, pull body up until chin over bar',
        images: [],
      ),
      Exercise(
        id: 'overhead_press',
        name: 'Overhead Press',
        description: 'Shoulder pressing movement',
        category: 'strength',
        muscleGroup: 'shoulders',
        equipment: 'barbell',
        instructions: 'Press barbell overhead from shoulder height',
        images: [],
      ),
    ];

    for (final exercise in defaultExercises) {
      await _databaseService.insertExercise(exercise);
    }

    await _loadExercises();
  }

  // Load predefined workout plans
  Future<void> _loadPredefinedPlans() async {
    final existingPlans = _workoutPlans.where((plan) => plan.isPredefined).toList();
    if (existingPlans.isNotEmpty) return;

    // Push/Pull/Legs Plan
    final pushWorkout = Workout(
      id: 'push_workout',
      name: 'Push Day',
      description: 'Chest, shoulders, and triceps workout',
      exercises: [
        WorkoutExercise(
          exerciseId: 'bench_press',
          exercise: _exercises.firstWhere((e) => e.id == 'bench_press'),
          sets: [
            ExerciseSet(reps: 8, weight: 0),
            ExerciseSet(reps: 8, weight: 0),
            ExerciseSet(reps: 8, weight: 0),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'overhead_press',
          exercise: _exercises.firstWhere((e) => e.id == 'overhead_press'),
          sets: [
            ExerciseSet(reps: 10, weight: 0),
            ExerciseSet(reps: 10, weight: 0),
            ExerciseSet(reps: 10, weight: 0),
          ],
        ),
      ],
      estimatedDuration: 60,
      difficulty: 'intermediate',
      tags: ['push', 'upper_body'],
    );

    final pullWorkout = Workout(
      id: 'pull_workout',
      name: 'Pull Day',
      description: 'Back and biceps workout',
      exercises: [
        WorkoutExercise(
          exerciseId: 'pull_up',
          exercise: _exercises.firstWhere((e) => e.id == 'pull_up'),
          sets: [
            ExerciseSet(reps: 8, weight: 0),
            ExerciseSet(reps: 8, weight: 0),
            ExerciseSet(reps: 8, weight: 0),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'deadlift',
          exercise: _exercises.firstWhere((e) => e.id == 'deadlift'),
          sets: [
            ExerciseSet(reps: 5, weight: 0),
            ExerciseSet(reps: 5, weight: 0),
            ExerciseSet(reps: 5, weight: 0),
          ],
        ),
      ],
      estimatedDuration: 60,
      difficulty: 'intermediate',
      tags: ['pull', 'upper_body'],
    );

    final legsWorkout = Workout(
      id: 'legs_workout',
      name: 'Leg Day',
      description: 'Lower body workout',
      exercises: [
        WorkoutExercise(
          exerciseId: 'squat',
          exercise: _exercises.firstWhere((e) => e.id == 'squat'),
          sets: [
            ExerciseSet(reps: 10, weight: 0),
            ExerciseSet(reps: 10, weight: 0),
            ExerciseSet(reps: 10, weight: 0),
          ],
        ),
      ],
      estimatedDuration: 45,
      difficulty: 'intermediate',
      tags: ['legs', 'lower_body'],
    );

    // Save workouts
    await _databaseService.insertWorkout(pushWorkout);
    await _databaseService.insertWorkout(pullWorkout);
    await _databaseService.insertWorkout(legsWorkout);

    // Create Push/Pull/Legs plan
    final pplPlan = WorkoutPlan(
      id: 'ppl_plan',
      name: 'Push/Pull/Legs',
      description: 'Classic 3-day split focusing on movement patterns',
      workoutIds: ['push_workout', 'pull_workout', 'legs_workout'],
      workouts: [pushWorkout, pullWorkout, legsWorkout],
      daysPerWeek: 3,
      planType: 'push_pull_legs',
      isPredefined: true,
      createdAt: DateTime.now(),
    );

    await _databaseService.insertWorkoutPlan(pplPlan);

    await _loadWorkouts();
    await _loadWorkoutPlans();
  }

  // Create workout
  Future<void> createWorkout(Workout workout) async {
    await _databaseService.insertWorkout(workout);
    await _loadWorkouts();
  }

  // Create workout plan
  Future<void> createWorkoutPlan(WorkoutPlan plan) async {
    await _databaseService.insertWorkoutPlan(plan);
    await _loadWorkoutPlans();
  }

  // Start workout session
  Future<void> startWorkoutSession(Workout workout) async {
    _currentSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: workout.id,
      workoutName: workout.name,
      startTime: DateTime.now(),
      exercises: workout.exercises.map((we) => SessionExercise(
        exerciseId: we.exerciseId,
        exerciseName: we.exercise.name,
        sets: we.sets.map((s) => SessionSet(
          reps: s.reps,
          weight: s.weight,
          duration: s.duration,
          timestamp: DateTime.now(),
        )).toList(),
      )).toList(),
    );
    notifyListeners();
  }

  // End workout session
  Future<void> endWorkoutSession() async {
    if (_currentSession != null) {
      final completedSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        duration: DateTime.now().difference(_currentSession!.startTime).inMinutes,
        completed: true,
      );
      
      await _databaseService.insertWorkoutSession(completedSession);
      _currentSession = null;
      await _loadWorkoutSessions();
    }
  }

  // Import workout plan from JSON
  Future<void> importWorkoutPlan(String jsonString) async {
    try {
      final Map<String, dynamic> planData = jsonDecode(jsonString);
      final plan = WorkoutPlan.fromJson(planData);
      await _databaseService.insertWorkoutPlan(plan);
      await _loadWorkoutPlans();
    } catch (e) {
      throw Exception('Failed to import workout plan: $e');
    }
  }

  // Export workout plan to JSON
  String exportWorkoutPlan(WorkoutPlan plan) {
    return jsonEncode(plan.toJson());
  }

  // Get exercises by muscle group
  List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return _exercises.where((exercise) => exercise.muscleGroup == muscleGroup).toList();
  }

  // Get recent workout sessions
  List<WorkoutSession> getRecentSessions({int limit = 10}) {
    return _workoutSessions.take(limit).toList();
  }
}