import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/ui/widgets/icon_button.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';
import 'package:kanban_frontend/features/projects/presentation/bloc/bloc.dart';
import 'package:kanban_frontend/features/projects/presentation/widgets/project_info_card.dart';

class ProjectInfoCardDemoScreen extends StatefulWidget {
  const ProjectInfoCardDemoScreen({super.key});

  @override
  State<ProjectInfoCardDemoScreen> createState() =>
      _ProjectInfoCardDemoScreenState();
}

class _ProjectInfoCardDemoScreenState extends State<ProjectInfoCardDemoScreen> {
  bool _hasRequestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasRequestedLoad) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _hasRequestedLoad = true;
      context.read<ProjectBloc>().add(
            ProjectLoadRequested(
              currentUserId: authState.userEntity.id,
              isAdmin: authState.userEntity.role == UserRole.admin,
            ),
          );
    }
  }

  Future<void> _createProjectDialog() async {
    final result = await _showProjectFormDialog();
    if (!mounted || result == null) {
      return;
    }

    context.read<ProjectBloc>().add(
          ProjectCreateRequested(
            name: result.name,
            description: result.description,
          ),
        );
  }

  Future<void> _updateProjectDialog(ProjectLoaded state) async {
    final selectedProject = state.selectedProject;
    if (selectedProject == null) {
      return;
    }

    final result = await _showProjectFormDialog(
      initialName: selectedProject.name,
      initialDescription: selectedProject.description,
    );

    if (!mounted || result == null) {
      return;
    }

    context.read<ProjectBloc>().add(
          ProjectUpdateRequested(
            projectId: selectedProject.id,
            name: result.name,
            description: result.description,
          ),
        );
  }

  Future<void> _deleteProjectDialog(ProjectLoaded state) async {
    final selectedProject = state.selectedProject;
    if (selectedProject == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Project'),
            content: Text('Delete "${selectedProject.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldDelete) {
      return;
    }

    context
        .read<ProjectBloc>()
        .add(ProjectDeleteRequested(projectId: selectedProject.id));
  }

  Future<void> _addUserDialog(ProjectLoaded state) async {
    final selectedProject = state.selectedProject;
    if (selectedProject == null) {
      return;
    }

    final controller = TextEditingController();
    final userId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User To Project'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'User ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              Navigator.of(context).pop(parsed);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (!mounted || userId == null) {
      return;
    }

    context.read<ProjectBloc>().add(
          ProjectAddUserRequested(
            projectId: selectedProject.id,
            userId: userId,
          ),
        );
  }

  Future<_ProjectFormResult?> _showProjectFormDialog({
    String? initialName,
    String? initialDescription,
  }) async {
    final nameController = TextEditingController(text: initialName ?? '');
    final descriptionController =
        TextEditingController(text: initialDescription ?? '');

    final result = await showDialog<_ProjectFormResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialName == null ? 'Create Project' : 'Update Project'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Project description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              if (name.isEmpty) {
                return;
              }
              Navigator.of(context).pop(
                _ProjectFormResult(
                  name: name,
                  description: description.isEmpty ? null : description,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: Text('Login is required to view projects.'));
    }

    final isAdmin = authState.userEntity.role == UserRole.admin;

    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectLoaded && state.notice != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.notice!)));
          context.read<ProjectBloc>().add(ProjectNoticeCleared());
        }
      },
      builder: (context, state) {
        if (state is ProjectLoading || state is ProjectInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProjectBloc>().add(
                          ProjectLoadRequested(
                            currentUserId: authState.userEntity.id,
                            isAdmin: isAdmin,
                          ),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final loadedState = state as ProjectLoaded;
        final selectedProject = loadedState.selectedProject;

        if (loadedState.projects.isEmpty || selectedProject == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No projects found.'),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  AddButton(
                    onPressed: _createProjectDialog,
                    text: 'Create Project',
                    size: const Size(220, 52),
                    icon: Icons.add,
                  ),
                ],
              ],
            ),
          );
        }

        final admins = loadedState.selectedProjectUsers
            .map(
              (user) => ProjectAdminUser(
                userId: user.userId,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
              ),
            )
            .toList();

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: loadedState.projects
                          .map(
                            (project) => ChoiceChip(
                              label: Text(project.name),
                              selected:
                                  loadedState.selectedProjectId == project.id,
                              onSelected: (_) {
                                context.read<ProjectBloc>().add(
                                      ProjectSelected(projectId: project.id),
                                    );
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isAdmin)
                          AddButton(
                            onPressed: _createProjectDialog,
                            text: 'Create Project',
                            size: const Size(220, 52),
                            icon: Icons.add,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProjectInfoCard(
                      projectName: selectedProject.name,
                      projectDescription: selectedProject.description,
                      admins: admins,
                      onAddAdmin: () => _addUserDialog(loadedState),
                      onDeleteProject: () => _deleteProjectDialog(loadedState),
                      onUpdateProject: () => _updateProjectDialog(loadedState),
                      onRemoveAdmin: (user) {
                        context.read<ProjectBloc>().add(
                              ProjectRemoveUserRequested(
                                projectId: selectedProject.id,
                                userId: user.userId,
                              ),
                            );
                      },
                      adminTableWidth: 900,
                      adminTableHeight: 280,
                      isAdmin: isAdmin,
                    ),
                  ],
                ),
              ),
            ),
            if (loadedState.isBusy)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        );
      },
    );
  }
}

class _ProjectFormResult {
  final String name;
  final String? description;

  const _ProjectFormResult({required this.name, this.description});
}
