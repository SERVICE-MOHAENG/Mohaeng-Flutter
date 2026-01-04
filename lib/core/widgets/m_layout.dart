import 'package:flutter/material.dart';

class MLayout extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final PreferredSizeWidget? appBar;

  const MLayout({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: body,
        appBar: appBar,
        backgroundColor: backgroundColor,
        bottomSheet: bottomSheet,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
