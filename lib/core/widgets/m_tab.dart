import 'package:flutter/material.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_screen.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view/ui/mypage_screen.dart';

class MTab extends StatefulWidget {
  const MTab({super.key});

  @override
  State<MTab> createState() => _MTabState();
}

class _MTabState extends State<MTab> {
  int _index = 0;
  late final PageController _pageController;

  final List<Widget> _pages = const [MainScreen(), MyPageScreen()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: MColor.white100,
          indicatorColor: MColor.primary100,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? MColor.gray800
                : MColor.gray400;
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? MColor.primary500
                : MColor.gray400;
            return IconThemeData(color: color, size: 24);
          }),
          elevation: 0,
        ),
        child: NavigationBar(
          selectedIndex: _index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (i) {
            setState(() => _index = i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            );
          },
          height: 80,
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
      ),
    );
  }
}
