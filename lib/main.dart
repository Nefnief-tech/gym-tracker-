import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/themes/app_theme.dart';
import 'package:gym_tracker/screens/home_screen.dart';
import 'package:gym_tracker/services/workout_service.dart';
import 'package:gym_tracker/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final databaseService = DatabaseService();
  await databaseService.initDatabase();
  
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  
  const MyApp({Key? key, required this.databaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider(
          create: (context) => WorkoutService(databaseService),
        ),
      ],
      child: MaterialApp(
        title: 'Gym Tracker',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}