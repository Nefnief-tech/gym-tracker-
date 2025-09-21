import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_service.dart';
import '../models/workout_session.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late PageController _pageController;
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutService>(
      builder: (context, workoutService, child) {
        final session = workoutService.currentSession;
        
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('No Active Workout')),
            body: const Center(
              child: Text('No workout session in progress'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(session.workoutName),
            actions: [
              IconButton(
                icon: const Icon(Icons.timer),
                onPressed: () => _showTimer(context),
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () => _showEndWorkoutDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Exercise ${_currentExerciseIndex + 1} of ${session.exercises.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          _getElapsedTime(session.startTime),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentExerciseIndex + 1) / session.exercises.length,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Exercise content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: session.exercises.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentExerciseIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final exercise = session.exercises[index];
                    return _buildExerciseView(exercise);
                  },
                ),
              ),
              
              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentExerciseIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousExercise,
                          child: const Text('Previous'),
                        ),
                      ),
                    if (_currentExerciseIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentExerciseIndex < session.exercises.length - 1
                            ? _nextExercise
                            : () => _showEndWorkoutDialog(context),
                        child: Text(
                          _currentExerciseIndex < session.exercises.length - 1
                              ? 'Next Exercise'
                              : 'Finish Workout',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseView(SessionExercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focus on proper form and controlled movements',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sets
          Text(
            'Sets',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: set.completed 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Set number
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: set.completed
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.outline,
                      child: Text(
                        '${setIndex + 1}',
                        style: TextStyle(
                          color: set.completed
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Set details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${set.reps} reps',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (set.weight > 0)
                            Text(
                              '${set.weight} kg',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                    
                    // Complete button
                    if (!set.completed)
                      ElevatedButton(
                        onPressed: () => _completeSet(exercise, setIndex),
                        child: const Text('Complete'),
                      )
                    else
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Rest timer (if not last set)
          if (exercise.sets.any((set) => !set.completed))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Rest Timer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '60 seconds',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement rest timer
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rest timer coming soon!'),
                          ),
                        );
                      },
                      child: const Text('Start Timer'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _completeSet(SessionExercise exercise, int setIndex) {
    // TODO: Implement set completion logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set ${setIndex + 1} completed!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _pageController.positions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showTimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rest Timer'),
        content: const Text('Rest timer functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEndWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Workout'),
        content: const Text('Are you sure you want to end this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endWorkout();
            },
            child: const Text('End Workout'),
          ),
        ],
      ),
    );
  }

  void _endWorkout() {
    final workoutService = Provider.of<WorkoutService>(context, listen: false);
    workoutService.endWorkoutSession();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _getElapsedTime(DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}