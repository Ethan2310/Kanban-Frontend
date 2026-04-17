import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kanban_frontend/core/routing/app_routes.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';

class MainDrawer extends StatelessWidget {
  final String currentLocation;
  final bool isPersistent;
  final ValueChanged<String>? onNavigateStart;

  const MainDrawer({
    super.key,
    required this.currentLocation,
    this.isPersistent = false,
    this.onNavigateStart,
  });

  void _navigate(BuildContext context, String route) {
    if (!isPersistent) {
      Navigator.of(context).pop();
    }
    if (currentLocation != route) {
      onNavigateStart?.call(route);
      context.go(route);
    }
  }

  Widget _buildUserHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name =
            state is AuthAuthenticated ? state.userEntity.fullName : 'Guest';
        final email = state is AuthAuthenticated ? state.userEntity.email : '';

        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          accountName: Text(name),
          accountEmail: Text(email),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: currentLocation == route,
      onTap: () => _navigate(context, route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerBody = ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildUserHeader(context),
        _buildNavItem(
          context: context,
          title: 'Home',
          icon: Icons.home_outlined,
          route: AppRoutes.home,
        ),
        _buildNavItem(
          context: context,
          title: 'Projects',
          icon: Icons.folder_outlined,
          route: AppRoutes.projects,
        ),
        _buildNavItem(
          context: context,
          title: 'Boards',
          icon: Icons.view_kanban_outlined,
          route: AppRoutes.boards,
        ),
        _buildNavItem(
          context: context,
          title: 'Lists',
          icon: Icons.list_alt_outlined,
          route: AppRoutes.lists,
        ),
        _buildNavItem(
          context: context,
          title: 'Tasks',
          icon: Icons.task_outlined,
          route: AppRoutes.tasks,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            if (!isPersistent) {
              Navigator.of(context).pop();
            }
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
        ),
      ],
    );

    if (isPersistent) {
      return Material(
        color: Theme.of(context).drawerTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        child: drawerBody,
      );
    }

    return Drawer(child: drawerBody);
  }
}
