import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/ui/widgets/icon_button.dart';
import 'package:kanban_frontend/core/ui/widgets/info_table.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';
import 'package:kanban_frontend/features/boards/presentation/bloc/bloc.dart';

class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key});

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  final Map<int, _BoardDraft> _drafts = <int, _BoardDraft>{};
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
      context.read<BoardBloc>().add(
            BoardLoadRequested(
              currentUserId: authState.userEntity.id,
              isAdmin: authState.userEntity.role == UserRole.admin,
            ),
          );
    }
  }

  @override
  void dispose() {
    for (final draft in _drafts.values) {
      draft.dispose();
    }
    super.dispose();
  }

  void _syncDrafts(List<BoardEntity> boards) {
    final activeIds = boards.map((e) => e.id).toSet();

    final removedIds =
        _drafts.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in removedIds) {
      _drafts.remove(id)?.dispose();
    }

    for (final board in boards) {
      final existing = _drafts[board.id];
      if (existing == null) {
        _drafts[board.id] = _BoardDraft.fromBoard(board);
        continue;
      }

      if (!existing.isDirty &&
          (existing.originalName != board.name ||
              existing.originalDescription != (board.description ?? ''))) {
        existing.dispose();
        _drafts[board.id] = _BoardDraft.fromBoard(board);
      }
    }
  }

  Future<void> _createBoardDialog(int projectId) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final shouldCreate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Create Board'),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Board name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldCreate) {
      return;
    }

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    context.read<BoardBloc>().add(
          BoardCreateRequested(
            name: name,
            description: description.isEmpty ? null : description,
            projectId: projectId,
          ),
        );
  }

  Future<void> _confirmDeleteBoard(BoardEntity board) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Board'),
            content: Text('Delete "${board.name}"?'),
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

    context.read<BoardBloc>().add(BoardDeleteRequested(boardId: board.id));
  }

  Widget _buildTable(BuildContext context, BoardLoaded state) {
    _syncDrafts(state.boards);

    return InfoTable<BoardEntity>(
      rows: state.boards,
      width: 1000,
      height: 420,
      emptyText: 'No boards found for this project.',
      columns: [
        InfoTableColumn<BoardEntity>(
          heading: 'Board Name',
          flex: 3,
          cellBuilder: (context, board) {
            final draft = _drafts[board.id]!;
            return TextField(
              controller: draft.nameController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            );
          },
        ),
        InfoTableColumn<BoardEntity>(
          heading: 'Description',
          flex: 4,
          cellBuilder: (context, board) {
            final draft = _drafts[board.id]!;
            return TextField(
              controller: draft.descriptionController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            );
          },
        ),
        InfoTableColumn<BoardEntity>(
          heading: 'Actions',
          flex: 3,
          cellBuilder: (context, board) {
            final draft = _drafts[board.id]!;
            final canUpdate = draft.isDirty && !state.isBusy;

            return Row(
              children: [
                AnimatedOpacity(
                  opacity: draft.isDirty ? 1 : 0.45,
                  duration: const Duration(milliseconds: 180),
                  child: ElevatedButton(
                    onPressed: canUpdate
                        ? () {
                            final name = draft.nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Board name cannot be empty.'),
                                ),
                              );
                              return;
                            }

                            final description =
                                draft.descriptionController.text.trim();
                            context.read<BoardBloc>().add(
                                  BoardUpdateRequested(
                                    boardId: board.id,
                                    name: name,
                                    description: description.isEmpty
                                        ? null
                                        : description,
                                  ),
                                );
                          }
                        : null,
                    child: const Text('Update Board'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed:
                      state.isBusy ? null : () => _confirmDeleteBoard(board),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete board',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: Text('Login is required to view boards.'));
    }

    final isAdmin = authState.userEntity.role == UserRole.admin;
    if (!isAdmin) {
      return const Center(
        child: Text('Boards management is available to admins only.'),
      );
    }

    return BlocConsumer<BoardBloc, BoardState>(
      listener: (context, state) {
        if (state is BoardLoaded && state.notice != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.notice!)));
          context.read<BoardBloc>().add(BoardNoticeCleared());
        }
      },
      builder: (context, state) {
        if (state is BoardInitial || state is BoardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BoardError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<BoardBloc>().add(
                          BoardLoadRequested(
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

        final loadedState = state as BoardLoaded;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Add board to project:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: loadedState.selectedProjectId,
                              items: loadedState.projects
                                  .map(
                                    (project) => DropdownMenuItem<int>(
                                      value: project.id,
                                      child: Text(project.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: loadedState.isBusy
                                  ? null
                                  : (projectId) {
                                      if (projectId == null) {
                                        return;
                                      }
                                      context.read<BoardBloc>().add(
                                            BoardProjectSelected(
                                              projectId: projectId,
                                            ),
                                          );
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconedButton(
                            onPressed: loadedState.isBusy ||
                                    loadedState.selectedProjectId == null
                                ? () {}
                                : () => _createBoardDialog(
                                      loadedState.selectedProjectId!,
                                    ),
                            text: 'Create Board',
                            size: const Size(220, 52),
                            icon: Icons.add,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTable(context, loadedState),
                    ],
                  ),
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

class _BoardDraft {
  final String originalName;
  final String originalDescription;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  _BoardDraft({
    required this.originalName,
    required this.originalDescription,
    required this.nameController,
    required this.descriptionController,
  });

  factory _BoardDraft.fromBoard(BoardEntity board) {
    return _BoardDraft(
      originalName: board.name,
      originalDescription: board.description ?? '',
      nameController: TextEditingController(text: board.name),
      descriptionController:
          TextEditingController(text: board.description ?? ''),
    );
  }

  bool get isDirty {
    return nameController.text.trim() != originalName ||
        descriptionController.text.trim() != originalDescription;
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}
