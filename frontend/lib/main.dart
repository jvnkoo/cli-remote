import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const ArchRemoteApp(),
    ),
  );
}

class ArchRemoteApp extends StatelessWidget {
  const ArchRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'LinuxRemote',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark), 
      home: const MainScreen(),
    );
  }
}
