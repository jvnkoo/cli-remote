import 'package:flutter/cupertino.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/root_screen.dart';

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
    return CupertinoApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemIndigo,
      ),
      home: const RootScreen(),
    );
  }
}