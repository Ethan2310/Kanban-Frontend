# BLoC Feature Implementation Guide

This document captures the exact patterns used in this project so any new feature BLoC can be implemented consistently. The Auth feature is used as the canonical reference throughout.

---

## Architecture Overview

Each feature follows a strict three-layer structure:

```
lib/features/<feature>/
├── data/
│   ├── datasources/        # Abstract + concrete data source classes
│   ├── models/             # JSON <-> Entity mapping (extend Entity)
│   └── repositories/       # Concrete repository implementations
├── domain/
│   ├── entities/           # Pure Dart business objects (extend BaseEntity or Equatable)
│   ├── repositories/       # Abstract repository contracts
│   └── usecases/           # One class per use case, implements UseCase<T, Params>
└── presentation/
    ├── bloc/               # BLoC, Event, State + barrel export
    ├── screens/
    └── widgets/
```

**Data flows strictly downward:** Presentation → Domain → Data. No layer imports from a layer above it.

---

## Step-by-Step: Implementing a Feature BLoC

### Step 1 — Domain: Entity

Create the pure business object. All entities extend `BaseEntity` (which itself extends `Equatable`) and must be `const`-constructable.

**Pattern** (`lib/features/<feature>/domain/entities/<feature>_entity.dart`):

```dart
import 'package:equatable/equatable.dart';
import 'package:kanban_frontend/core/entities/base_entity.dart'; // if applicable

class ProjectEntity extends Equatable {
  final int projectId;
  final String name;
  final String? description;

  const ProjectEntity({
    required this.projectId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [projectId, name, description];
}
```

> Note: Not every entity needs to extend `BaseEntity`. Use `BaseEntity` for full audit-trail objects (id, guid, createdOn, updatedOn, isActive). Use plain `Equatable` for lightweight response shapes like `ProjectEntity`.

---

### Step 2 — Domain: Repository Contract

Define the abstract interface. Return types are always `Future<Either<Failure, T>>` using the `dartz` package.

**Pattern** (`lib/features/<feature>/domain/repositories/<feature>_repository.dart`):

```dart
import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/<feature>/domain/entities/<feature>_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<ProjectEntity>>> getProjects();
  Future<Either<Failure, ProjectEntity>> createProject({
    required String name,
    String? description,
  });
  Future<Either<Failure, ProjectEntity>> updateProject({
    required int projectId,
    String? name,
    String? description,
  });
  Future<Either<Failure, void>> deleteProject({required int projectId});
}
```

---

### Step 3 — Domain: Use Cases

One file (and one class) per operation. Every use case implements `UseCase<ReturnType, ParamsType>`. For operations with no parameters use `NoParams`.

**Pattern** (`lib/features/<feature>/domain/usecases/<action>_usecase.dart`):

```dart
import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

// --- Get Projects ---
class GetProjectsUseCase implements UseCase<List<ProjectEntity>, NoParams> {
  final ProjectRepository repository;
  GetProjectsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ProjectEntity>>> call(NoParams params) =>
      repository.getProjects();
}

// --- Create Project ---
class CreateProjectUseCase implements UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectRepository repository;
  CreateProjectUseCase({required this.repository});

  @override
  Future<Either<Failure, ProjectEntity>> call(CreateProjectParams params) =>
      repository.createProject(name: params.name, description: params.description);
}

class CreateProjectParams {
  final String name;
  final String? description;
  CreateProjectParams({required this.name, this.description});
}

// Repeat the same pattern for UpdateProjectUseCase and DeleteProjectUseCase
```

---

### Step 4 — Data: Model

The model extends the entity and adds `fromJson` / `toJson`. It lives purely in the data layer.

**Pattern** (`lib/features/<feature>/data/models/<feature>_model.dart`):

```dart
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.projectId,
    required super.name,
    super.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'projectId': projectId,
        'name': name,
        if (description != null) 'description': description,
      };
}
```

---

### Step 5 — Data: Remote Data Source

Define the abstract contract and the `Dio`-based implementation. Map HTTP errors to typed exceptions from `core/error/exceptions.dart`. The BLoC never sees `DioException`; it only ever sees `Failure` subclasses (the repository does the translation).

**Pattern** (`lib/features/<feature>/data/datasources/<feature>_remote_datasource.dart`):

```dart
import 'package:dio/dio.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/features/projects/data/models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject({required String name, String? description});
  Future<ProjectModel> updateProject({required int projectId, String? name, String? description});
  Future<void> deleteProject({required int projectId});
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio dio;

  static const _projectsEndpoint = '/api/projects';

  ProjectRemoteDataSourceImpl({required this.dio});

  String? _detail(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data['detail'] as String?;
    return null;
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await dio.get(_projectsEndpoint);
      final list = response.data['projects'] as List<dynamic>;
      return list.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _detail(e) ?? 'Failed to fetch projects.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ProjectModel> createProject({required String name, String? description}) async {
    try {
      final response = await dio.post(
        _projectsEndpoint,
        data: {'name': name, if (description != null) 'description': description},
      );
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _detail(e) ?? 'Failed to create project.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ProjectModel> updateProject({
    required int projectId,
    String? name,
    String? description,
  }) async {
    try {
      final response = await dio.patch(
        '$_projectsEndpoint/$projectId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: _detail(e) ?? 'Project not found.');
      }
      throw ServerException(
        message: _detail(e) ?? 'Failed to update project.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteProject({required int projectId}) async {
    try {
      await dio.delete('$_projectsEndpoint/$projectId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: _detail(e) ?? 'Project not found.');
      }
      throw ServerException(
        message: _detail(e) ?? 'Failed to delete project.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
```

---

### Step 6 — Data: Repository Implementation

Wraps data source calls in `try/catch`, maps exceptions to `Failure` subclasses, and returns `Either`.

**Pattern** (`lib/features/<feature>/data/repositories/<feature>_repository_impl.dart`):

```dart
import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() async {
    try {
      final projects = await remoteDataSource.getProjects();
      return Right(projects);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> createProject({
    required String name,
    String? description,
  }) async {
    try {
      final project = await remoteDataSource.createProject(
        name: name,
        description: description,
      );
      return Right(project);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject({
    required int projectId,
    String? name,
    String? description,
  }) async {
    try {
      final project = await remoteDataSource.updateProject(
        projectId: projectId,
        name: name,
        description: description,
      );
      return Right(project);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject({required int projectId}) async {
    try {
      await remoteDataSource.deleteProject(projectId: projectId);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
    }
  }
}
```

---

### Step 7 — Presentation: Events

Events use `part of` to share the BLoC's library scope. Dataless events are empty classes; data-carrying events declare `final` fields and override `props`.

**Pattern** (`lib/features/<feature>/presentation/bloc/<feature>_event.dart`):

```dart
part of 'project_bloc.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Dataless
class ProjectLoadRequested extends ProjectEvent {}

// Data-carrying
class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String? description;

  ProjectCreateRequested({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class ProjectUpdateRequested extends ProjectEvent {
  final int projectId;
  final String? name;
  final String? description;

  ProjectUpdateRequested({required this.projectId, this.name, this.description});

  @override
  List<Object?> get props => [projectId, name, description];
}

class ProjectDeleteRequested extends ProjectEvent {
  final int projectId;

  ProjectDeleteRequested({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}
```

---

### Step 8 — Presentation: States

States extend a sealed abstract base (also `part of` the BLoC file). Every state that carries data overrides `props`. Include an error enum when multiple distinct error types are possible.

**Pattern** (`lib/features/<feature>/presentation/bloc/<feature>_state.dart`):

```dart
part of 'project_bloc.dart';

enum ProjectErrorType { generic, notFound, server }

abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<ProjectEntity> projects;

  ProjectLoaded({required List<ProjectEntity> projects})
      : assert(projects.isNotEmpty),   // guard: emit ProjectEmpty for the empty case
        projects = List.unmodifiable(projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectEmpty extends ProjectState {}

class ProjectOperationSuccess extends ProjectState {
  /// The updated/created/deleted project id – lets UI react without re-fetching.
  final int projectId;
  ProjectOperationSuccess({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class ProjectError extends ProjectState {
  final String message;
  final ProjectErrorType type;

  ProjectError({required this.message, this.type = ProjectErrorType.generic});

  @override
  List<Object?> get props => [message, type];
}
```

> **Empty vs Loaded:** Per the architecture doc, use a dedicated `ProjectEmpty` state rather than a nullable list. The `ProjectLoaded` constructor asserts non-empty so the compiler cannot accidentally reach that state with an empty list.

---

### Step 9 — Presentation: BLoC Class

The BLoC class imports use cases via constructor injection. Each event handler is a private method. The method signature is always `Future<void> _onEventName(EventType event, Emitter<State> emit)`.

**Pattern** (`lib/features/<feature>/presentation/bloc/<feature>_bloc.dart`):

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:kanban_frontend/core/error/failures.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;
  final CreateProjectUseCase createProjectUseCase;
  final UpdateProjectUseCase updateProjectUseCase;
  final DeleteProjectUseCase deleteProjectUseCase;

  ProjectBloc({
    required this.getProjectsUseCase,
    required this.createProjectUseCase,
    required this.updateProjectUseCase,
    required this.deleteProjectUseCase,
  }) : super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onLoadRequested);
    on<ProjectCreateRequested>(_onCreateRequested);
    on<ProjectUpdateRequested>(_onUpdateRequested);
    on<ProjectDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ProjectLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    final result = await getProjectsUseCase(NoParams());

    result.fold(
      (failure) => emit(ProjectError(
        message: _mapFailure(failure),
        type: _mapErrorType(failure),
      )),
      (projects) => projects.isEmpty
          ? emit(ProjectEmpty())
          : emit(ProjectLoaded(projects: projects)),
    );
  }

  Future<void> _onCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    final result = await createProjectUseCase(
      CreateProjectParams(name: event.name, description: event.description),
    );

    result.fold(
      (failure) => emit(ProjectError(
        message: _mapFailure(failure),
        type: _mapErrorType(failure),
      )),
      (project) => emit(ProjectOperationSuccess(projectId: project.projectId)),
    );
  }

  Future<void> _onUpdateRequested(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    final result = await updateProjectUseCase(
      UpdateProjectParams(
        projectId: event.projectId,
        name: event.name,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(ProjectError(
        message: _mapFailure(failure),
        type: _mapErrorType(failure),
      )),
      (project) => emit(ProjectOperationSuccess(projectId: project.projectId)),
    );
  }

  Future<void> _onDeleteRequested(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    final result = await deleteProjectUseCase(
      DeleteProjectParams(projectId: event.projectId),
    );

    result.fold(
      (failure) => emit(ProjectError(
        message: _mapFailure(failure),
        type: _mapErrorType(failure),
      )),
      (_) => emit(ProjectOperationSuccess(projectId: event.projectId)),
    );
  }

  // --- helpers (kept private, no domain logic) ---

  String _mapFailure(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error: ${failure.message ?? 'Unexpected error.'}';
    }
    if (failure is NotFoundFailure) {
      return 'Not found: ${failure.message}';
    }
    return 'An unexpected error occurred.';
  }

  ProjectErrorType _mapErrorType(Failure failure) {
    if (failure is ServerFailure) return ProjectErrorType.server;
    if (failure is NotFoundFailure) return ProjectErrorType.notFound;
    return ProjectErrorType.generic;
  }
}
```

---

### Step 10 — Barrel Export

Create a single export file so consumers only import one path.

**Pattern** (`lib/features/<feature>/presentation/bloc/bloc.dart`):

```dart
export 'project_bloc.dart';
```

---

### Step 11 — Dependency Injection

Register in `lib/injection_container.dart` following this order:
1. BLoC (`registerFactory` — new instance per injection)
2. Use cases (`registerLazySingleton`)
3. Repository interface → implementation (`registerLazySingleton<Abstract>`)
4. Data sources (`registerLazySingleton<Abstract>`)

**Pattern** (add to `injection_container.dart`):

```dart
// ── Projects ──────────────────────────────────────────────
sl.registerFactory(
  () => ProjectBloc(
    getProjectsUseCase: sl(),
    createProjectUseCase: sl(),
    updateProjectUseCase: sl(),
    deleteProjectUseCase: sl(),
  ),
);

sl.registerLazySingleton(() => GetProjectsUseCase(repository: sl()));
sl.registerLazySingleton(() => CreateProjectUseCase(repository: sl()));
sl.registerLazySingleton(() => UpdateProjectUseCase(repository: sl()));
sl.registerLazySingleton(() => DeleteProjectUseCase(repository: sl()));

sl.registerLazySingleton<ProjectRepository>(
  () => ProjectRepositoryImpl(remoteDataSource: sl()),
);

sl.registerLazySingleton<ProjectRemoteDataSource>(
  () => ProjectRemoteDataSourceImpl(dio: sl()),
);
```

> The shared `Dio` instance (`sl<Dio>()`) is already registered for Auth and is reused here.

---

## Key Rules Summary

| Rule | Detail |
|---|---|
| `part of` for events/states | Always declare `part of '<feature>_bloc.dart'` — eliminates import bloat |
| Barrel export | `bloc.dart` exports only `<feature>_bloc.dart` |
| BLoC is stateless | No stored properties beyond injected use cases. State lives only in the emitted `State` |
| `registerFactory` for BLoC | A new BLoC instance per widget tree injection |
| `registerLazySingleton` for everything else | Use cases and repositories are stateless singletons |
| Either<Failure, T> everywhere | Repository and use case return types are always `Either`. BLoC folds, never throws |
| Exceptions → Failures in repository | Data sources throw typed exceptions; repositories catch them and return `Left(Failure)` |
| Empty vs Loaded states | Emit `FeatureEmpty` for empty lists; guard `FeatureLoaded` with a non-empty assertion |
| Error enum per feature | `FeatureErrorType` enum on the error state lets UI branch without string matching |

---

## File Checklist for a New Feature

```
lib/features/<feature>/
├── domain/
│   ├── entities/<feature>_entity.dart          ✅ extends Equatable
│   ├── repositories/<feature>_repository.dart  ✅ abstract, Either returns
│   └── usecases/
│       ├── get_<feature>s_usecase.dart
│       ├── create_<feature>_usecase.dart
│       ├── update_<feature>_usecase.dart
│       └── delete_<feature>_usecase.dart
├── data/
│   ├── models/<feature>_model.dart             ✅ extends entity, fromJson
│   ├── datasources/<feature>_remote_datasource.dart
│   └── repositories/<feature>_repository_impl.dart
└── presentation/
    └── bloc/
        ├── <feature>_bloc.dart                 ✅ part directives here
        ├── <feature>_event.dart                ✅ part of bloc
        ├── <feature>_state.dart                ✅ part of bloc
        └── bloc.dart                           ✅ barrel export
```

Add to `injection_container.dart`: BLoC → Use cases → Repository → Data sources.
