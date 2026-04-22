import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';
import 'package:kanban_frontend/features/projects/presentation/bloc/bloc.dart';
import 'package:kanban_frontend/router.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const KanbanFrontendApp());
}

class KanbanFrontendApp extends StatelessWidget {
  const KanbanFrontendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider<ProjectBloc>(
          create: (_) => di.sl<ProjectBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final appRouter = AppRouter(authBloc: authBloc);

          return MaterialApp.router(
            title: 'Kanban Board',
            routerConfig: appRouter.router,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
          );
        },
      ),
    );
  }
}
