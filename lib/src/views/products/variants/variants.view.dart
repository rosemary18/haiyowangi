import 'package:flutter/material.dart';

class VariantsView extends StatefulWidget {
  const VariantsView({super.key});

  @override
  State<VariantsView> createState() => _VariantsViewState();
}

class _VariantsViewState extends State<VariantsView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Variants"),
      ),
    );
  }
}