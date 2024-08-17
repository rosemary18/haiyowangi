import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: const Column(
          children: [
            SkletonView()
          ],
        ),
      ),
    );
  }
}