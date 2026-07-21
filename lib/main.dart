import 'package:flutter/material.dart';
//import 'package:task_app/screens/add_task_screen.dart';
import 'package:task_app/screens/dashboard_screen.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  await Hive.openBox<Map>('tasks_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
