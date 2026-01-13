import 'package:flutter/material.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MLayout(body: Center(child: Text('mainScreen')));
  }
}
