import 'package:flutter/material.dart';
import 'package:kanban_frontend/core/ui/widgets/icon_button.dart';

class MockFeatureScreen extends StatelessWidget {
  final String title;

  const MockFeatureScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title screen (mock)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        AddButton(
            onPressed: () {/* TODO: Implement action */},
            text: 'Add $title',
            backgroundColor: Colors.black,
            size: const Size(50, 10),
            icon: Icons.add),
      ],
    ));
  }
}
