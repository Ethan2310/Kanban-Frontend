import 'package:flutter/material.dart';
import 'package:kanban_frontend/core/ui/widgets/main_drawer.dart';

class MainShellScreen extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const MainShellScreen({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  static const _breakpoint = 900.0;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  bool _isNavigating = false;

  void _handleNavigateStart(String route) {
    if (route == widget.currentLocation) {
      return;
    }

    if (!_isNavigating) {
      setState(() {
        _isNavigating = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentLocation != widget.currentLocation && _isNavigating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _isNavigating = false;
        });
      });
    }
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
        if (_isNavigating)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout =
            constraints.maxWidth >= MainShellScreen._breakpoint;

        if (isWideLayout) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kanban Board')),
            body: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: MainDrawer(
                    currentLocation: widget.currentLocation,
                    isPersistent: true,
                    onNavigateStart: _handleNavigateStart,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildContent()),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Kanban Board')),
          drawer: MainDrawer(
            currentLocation: widget.currentLocation,
            onNavigateStart: _handleNavigateStart,
          ),
          body: _buildContent(),
        );
      },
    );
  }
}
