import 'package:flutter/material.dart';

class KanbanFrontendApp extends StatelessWidget {
  const KanbanFrontendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanban Frontend',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Kanban frontend shell ready'),
        ),
      ),
    );
  }
}
