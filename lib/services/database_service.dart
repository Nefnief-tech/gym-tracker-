import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'gym_tracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create exercises table
        await db.execute('''
          CREATE TABLE exercises (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT,
            muscle_group TEXT,
            equipment TEXT,
            instructions TEXT,
            images TEXT
          )
        ''');

        // Create workouts table
        await db.execute('''
          CREATE TABLE workouts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            exercises TEXT,
            estimated_duration INTEGER,
            difficulty TEXT,
            tags TEXT,
            last_performed TEXT,
            times_performed INTEGER DEFAULT 0
          )
        ''');

        // Create workout_plans table
        await db.execute('''
          CREATE TABLE workout_plans (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            workout_ids TEXT,
            workouts TEXT,
            days_per_week INTEGER,
            plan_type TEXT,
            is_predefined INTEGER DEFAULT 0,
            created_at TEXT,
            last_modified TEXT
          )
        ''');

        // Create workout_sessions table
        await db.execute('''
          CREATE TABLE workout_sessions (
            id TEXT PRIMARY KEY,
            workout_id TEXT,
            workout_name TEXT,
            start_time TEXT,
            end_time TEXT,
            duration INTEGER,
            completed INTEGER DEFAULT 0,
            notes TEXT,
            exercises TEXT
          )
        ''');
      },
    );
  }

  // Exercise operations
  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', {
      'id': exercise.id,
      'name': exercise.name,
      'description': exercise.description,
      'category': exercise.category,
      'muscle_group': exercise.muscleGroup,
      'equipment': exercise.equipment,
      'instructions': exercise.instructions,
      'images': jsonEncode(exercise.images),
    });
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    
    return List.generate(maps.length, (i) {
      return Exercise(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'] ?? '',
        category: maps[i]['category'] ?? '',
        muscleGroup: maps[i]['muscle_group'] ?? '',
        equipment: maps[i]['equipment'] ?? '',
        instructions: maps[i]['instructions'] ?? '',
        images: List<String>.from(jsonDecode(maps[i]['images'] ?? '[]')),
      );
    });
  }

  // Workout operations
  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', {
      'id': workout.id,
      'name': workout.name,
      'description': workout.description,
      'exercises': jsonEncode(workout.exercises.map((e) => e.toJson()).toList()),
      'estimated_duration': workout.estimatedDuration,
      'difficulty': workout.difficulty,
      'tags': jsonEncode(workout.tags),
      'last_performed': workout.lastPerformed?.toIso8601String(),
      'times_performed': workout.timesPerformed,
    });
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts');
    
    return List.generate(maps.length, (i) {
      final exercisesJson = jsonDecode(maps[i]['exercises'] ?? '[]') as List;
      final exercises = exercisesJson.map((e) => WorkoutExercise.fromJson(e)).toList();
      
      return Workout(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'] ?? '',
        exercises: exercises,
        estimatedDuration: maps[i]['estimated_duration'] ?? 0,
        difficulty: maps[i]['difficulty'] ?? '',
        tags: List<String>.from(jsonDecode(maps[i]['tags'] ?? '[]')),
        lastPerformed: maps[i]['last_performed'] != null 
            ? DateTime.parse(maps[i]['last_performed']) 
            : null,
        timesPerformed: maps[i]['times_performed'] ?? 0,
      );
    });
  }

  // Workout plan operations
  Future<int> insertWorkoutPlan(WorkoutPlan plan) async {
    final db = await database;
    return await db.insert('workout_plans', {
      'id': plan.id,
      'name': plan.name,
      'description': plan.description,
      'workout_ids': jsonEncode(plan.workoutIds),
      'workouts': jsonEncode(plan.workouts.map((w) => w.toJson()).toList()),
      'days_per_week': plan.daysPerWeek,
      'plan_type': plan.planType,
      'is_predefined': plan.isPredefined ? 1 : 0,
      'created_at': plan.createdAt.toIso8601String(),
      'last_modified': plan.lastModified?.toIso8601String(),
    });
  }

  Future<List<WorkoutPlan>> getAllWorkoutPlans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workout_plans');
    
    return List.generate(maps.length, (i) {
      final workoutsJson = jsonDecode(maps[i]['workouts'] ?? '[]') as List;
      final workouts = workoutsJson.map((w) => Workout.fromJson(w)).toList();
      
      return WorkoutPlan(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'] ?? '',
        workoutIds: List<String>.from(jsonDecode(maps[i]['workout_ids'] ?? '[]')),
        workouts: workouts,
        daysPerWeek: maps[i]['days_per_week'] ?? 0,
        planType: maps[i]['plan_type'] ?? '',
        isPredefined: maps[i]['is_predefined'] == 1,
        createdAt: DateTime.parse(maps[i]['created_at']),
        lastModified: maps[i]['last_modified'] != null 
            ? DateTime.parse(maps[i]['last_modified']) 
            : null,
      );
    });
  }

  // Workout session operations
  Future<int> insertWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.insert('workout_sessions', {
      'id': session.id,
      'workout_id': session.workoutId,
      'workout_name': session.workoutName,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime?.toIso8601String(),
      'duration': session.duration,
      'completed': session.completed ? 1 : 0,
      'notes': session.notes,
      'exercises': jsonEncode(session.exercises.map((e) => e.toJson()).toList()),
    });
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workout_sessions', orderBy: 'start_time DESC');
    
    return List.generate(maps.length, (i) {
      final exercisesJson = jsonDecode(maps[i]['exercises'] ?? '[]') as List;
      final exercises = exercisesJson.map((e) => SessionExercise.fromJson(e)).toList();
      
      return WorkoutSession(
        id: maps[i]['id'],
        workoutId: maps[i]['workout_id'],
        workoutName: maps[i]['workout_name'],
        startTime: DateTime.parse(maps[i]['start_time']),
        endTime: maps[i]['end_time'] != null ? DateTime.parse(maps[i]['end_time']) : null,
        duration: maps[i]['duration'] ?? 0,
        completed: maps[i]['completed'] == 1,
        notes: maps[i]['notes'] ?? '',
        exercises: exercises,
      );
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}