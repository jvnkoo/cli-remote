import 'package:flutter/cupertino.dart';
import 'main_screen.dart';
import 'settings_screen.dart';
import '../widgets/tab_bar.dart' as custom;

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: custom.TabBar(),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const MainScreen();
          case 1:
            // return const CupertinoPageScaffold(
            //   navigationBar: CupertinoNavigationBar(middle: Text("Settings")),
            //   child: Center(child: Text("Settings Screen")),
            // );
            return const SettingsScreen();
          default:
            return const MainScreen();
        }
      },
    );
  }
}