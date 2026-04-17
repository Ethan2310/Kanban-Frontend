import 'package:flutter/material.dart';

class MockFeatureScreen extends StatelessWidget {
  final String title;

  const MockFeatureScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title screen (mock)',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
