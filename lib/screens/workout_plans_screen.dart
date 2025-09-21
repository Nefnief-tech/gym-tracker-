import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/workout_service.dart';
import '../models/workout.dart';
import '../widgets/workout_plan_card.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import Plan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Create Plan'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'import':
                  _importWorkoutPlan();
                  break;
                case 'create':
                  _showCreatePlanDialog();
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Plans'),
            Tab(text: 'Predefined'),
          ],
        ),
      ),
      body: Consumer<WorkoutService>(
        builder: (context, workoutService, child) {
          final myPlans = workoutService.workoutPlans
              .where((plan) => !plan.isPredefined)
              .toList();
          final predefinedPlans = workoutService.workoutPlans
              .where((plan) => plan.isPredefined)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // My Plans tab
              _buildPlansTab(myPlans, 'My Plans', true),
              // Predefined Plans tab
              _buildPlansTab(predefinedPlans, 'Predefined Plans', false),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlansTab(List<WorkoutPlan> plans, String title, bool allowEdit) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add_check,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              allowEdit ? 'No custom plans yet' : 'No predefined plans',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              allowEdit 
                  ? 'Create your first workout plan'
                  : 'Predefined plans will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            if (allowEdit) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreatePlanDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Plan'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WorkoutPlanCard(
            plan: plan,
            onTap: () => _showPlanDetails(plan),
            onExport: allowEdit ? () => _exportWorkoutPlan(plan) : null,
            onEdit: allowEdit ? () => _editWorkoutPlan(plan) : null,
          ),
        );
      },
    );
  }

  void _showPlanDetails(WorkoutPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  plan.description,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Plan info
                      Row(
                        children: [
                          _buildInfoChip(
                            '${plan.daysPerWeek} days/week',
                            Icons.event,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            plan.planType,
                            Icons.category,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            '${plan.workouts.length} workouts',
                            Icons.fitness_center,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Workouts
                      Text(
                        'Workouts',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      ...plan.workouts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final workout = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(workout.name),
                            subtitle: Text(
                              '${workout.exercises.length} exercises • ${workout.estimatedDuration} min',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // TODO: Show workout details
                            },
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      if (!plan.isPredefined) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _exportWorkoutPlan(plan);
                                },
                                icon: const Icon(Icons.file_download),
                                label: const Text('Export'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _editWorkoutPlan(plan);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _duplicatePlan(plan);
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Duplicate Plan'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Workout Plan'),
        content: const Text('Custom workout plan creation coming soon! This feature will allow you to build your own training programs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editWorkoutPlan(WorkoutPlan plan) {
    // TODO: Implement plan editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan editing coming soon!'),
      ),
    );
  }

  void _duplicatePlan(WorkoutPlan plan) {
    // TODO: Implement plan duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan duplication coming soon!'),
      ),
    );
  }

  Future<void> _importWorkoutPlan() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        
        final workoutService = Provider.of<WorkoutService>(context, listen: false);
        await workoutService.importWorkoutPlan(jsonString);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout plan imported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportWorkoutPlan(WorkoutPlan plan) async {
    try {
      final workoutService = Provider.of<WorkoutService>(context, listen: false);
      final jsonString = workoutService.exportWorkoutPlan(plan);
      
      // TODO: Implement file saving
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export functionality coming soon!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}