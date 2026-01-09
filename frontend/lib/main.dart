import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ArchRemoteApp());
}

class ArchRemoteApp extends StatelessWidget {
  const ArchRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LinuxRemote',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark), 
      home: const MainScreen(),
    );
  }
}
