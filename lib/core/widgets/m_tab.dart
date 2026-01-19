import 'package:flutter/material.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_screen.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view/ui/mypage_screen.dart';

class MTab extends StatefulWidget {
  const MTab({super.key});

  @override
  State<MTab> createState() => _MTabState();
}

class _MTabState extends State<MTab> {
  int _index = 0;

  final List<Widget> _pages = const [
    MainScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 68,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
