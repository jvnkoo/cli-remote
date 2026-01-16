import 'package:flutter/cupertino.dart';
import '../services/signalr_service.dart';
import 'main_screen.dart';
import 'settings_screen.dart';
import '../widgets/tab_bar.dart' as custom;

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final SignalRService _signalRService = SignalRService();

  @override
  void initState() {
    super.initState();
    _signalRService.addListener(_update);
  }

  @override
  void dispose() {
    _signalRService.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isConnecting = !_signalRService.isConnected;

    return CupertinoTabScaffold(
      tabBar: custom.TabBar(),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return MainScreen(isConnecting: isConnecting);
          case 1:
            return SettingsScreen(isConnecting: isConnecting);
          default:
            return MainScreen(isConnecting: isConnecting);
        }
      },
    );
  }
}