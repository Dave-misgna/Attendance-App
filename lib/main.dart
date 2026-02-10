import 'package:flutter/material.dart';
import 'package:newhope_attendance/core/navigation/route.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  final AppRoutes appRoutes = AppRoutes();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'New Hope Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: appRoutes.route,
    );
  }
}




