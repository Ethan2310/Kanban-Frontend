import 'package:flutter/material.dart';
import 'package:kanban_frontend/features/projects/presentation/widgets/project_info_card.dart';

class ProjectInfoCardDemoScreen extends StatefulWidget {
  const ProjectInfoCardDemoScreen({super.key});

  @override
  State<ProjectInfoCardDemoScreen> createState() =>
      _ProjectInfoCardDemoScreenState();
}

class _ProjectInfoCardDemoScreenState extends State<ProjectInfoCardDemoScreen> {
  final List<ProjectAdminUser> _admins = [
    const ProjectAdminUser(
      firstName: 'Avery',
      lastName: 'Cole',
      email: 'avery.cole@example.com',
    ),
    const ProjectAdminUser(
      firstName: 'Jules',
      lastName: 'Rivera',
      email: 'jules.rivera@example.com',
    ),
    const ProjectAdminUser(
      firstName: 'Morgan',
      lastName: 'Patel',
      email: 'morgan.patel@example.com',
    ),
  ];

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _addAdmin() {
    setState(() {
      _admins.add(
        ProjectAdminUser(
          firstName: 'New',
          lastName: 'User ${_admins.length + 1}',
          email: 'new.user${_admins.length + 1}@example.com',
        ),
      );
    });
  }

  void _removeAdmin(ProjectAdminUser user) {
    setState(() {
      _admins.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ProjectInfoCard(
          projectName: 'Kanban Modernization',
          projectDescription:
              'A shared workspace for roadmap planning, stories, and delivery workflows.',
          admins: _admins,
          onAddAdmin: _addAdmin,
          onDeleteProject: () => _showMessage('Delete Project pressed'),
          onUpdateProject: () => _showMessage('Update Project pressed'),
          onRemoveAdmin: _removeAdmin,
          adminTableWidth: 900,
          adminTableHeight: 280,
        ),
      ),
    );
  }
}
