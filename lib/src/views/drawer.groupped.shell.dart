import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
class DrawerGroupedShell extends StatefulWidget {

  final Widget child;
  const DrawerGroupedShell({super.key, required this.child});

  @override
  State<DrawerGroupedShell> createState() => _DrawerGroupedShellState();
}

class _DrawerGroupedShellState extends State<DrawerGroupedShell> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: const Drawer(
        width: 300,
        child: DrawerApp(),
      ),
      appBar: const DashboardHeader(),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xFF0D0D0D),
            child: widget.child,
          ),
        ],
      )
    );
  }
}