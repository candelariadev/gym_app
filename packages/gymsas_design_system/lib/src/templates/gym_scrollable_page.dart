import 'package:flutter/material.dart';

class GymScrollablePage extends StatelessWidget {
  const GymScrollablePage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
    this.backgroundColor = const Color(0xFFF7F7FB),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(padding: padding, child: child),
      ),
    );
  }
}
