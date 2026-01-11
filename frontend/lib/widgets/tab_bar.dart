import 'package:flutter/cupertino.dart';

class TabBar extends CupertinoTabBar {
  TabBar({super.key})
      : super(
    backgroundColor: CupertinoColors.black.withOpacity(0.8),
    activeColor: CupertinoColors.systemIndigo,
    inactiveColor: CupertinoColors.systemGrey,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.greaterthan_square),
        label: 'Terminal',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.settings),
        label: 'Settings',
      ),
    ],
  );
}