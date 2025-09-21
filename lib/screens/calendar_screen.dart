import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/workout_service.dart';
import '../models/workout_session.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Consumer<WorkoutService>(
        builder: (context, workoutService, child) {
          return Column(
            children: [
              // Calendar
              Card(
                margin: const EdgeInsets.all(16),
                child: TableCalendar<WorkoutSession>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    return workoutService.workoutSessions
                        .where((session) => isSameDay(session.startTime, day))
                        .toList();
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).primaryColor,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              
              // Selected day workouts
              Expanded(
                child: _buildSelectedDayWorkouts(workoutService),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleWorkoutDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSelectedDayWorkouts(WorkoutService workoutService) {
    final selectedDaySessions = workoutService.workoutSessions
        .where((session) => isSameDay(session.startTime, _selectedDay))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Workouts for ${_formatSelectedDate()}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (selectedDaySessions.isNotEmpty)
                Chip(
                  label: Text('${selectedDaySessions.length}'),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: selectedDaySessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No workouts scheduled',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to schedule a workout',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedDaySessions.length,
                    itemBuilder: (context, index) {
                      final session = selectedDaySessions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: session.completed 
                                ? Colors.green 
                                : Theme.of(context).primaryColor,
                            child: Icon(
                              session.completed ? Icons.check : Icons.schedule,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(session.workoutName),
                          subtitle: Text(
                            '${_formatTime(session.startTime)} • ${session.duration} min',
                          ),
                          trailing: session.completed
                              ? null
                              : PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    // TODO: Implement edit/delete functionality
                                  },
                                ),
                          onTap: () {
                            // TODO: Show session details
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    if (isSameDay(_selectedDay, today)) {
      return 'Today';
    } else if (isSameDay(_selectedDay, tomorrow)) {
      return 'Tomorrow';
    } else if (isSameDay(_selectedDay, yesterday)) {
      return 'Yesterday';
    } else {
      return '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showScheduleWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Workout'),
        content: const Text('Workout scheduling coming soon! This feature will allow you to plan workouts in advance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}