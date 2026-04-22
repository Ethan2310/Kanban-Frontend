# BLoC Feature Implementation Guide (Data + Domain + Presentation)

This guide documents the canonical patterns to implement a feature for BLoC consumption across Domain, Data, and Presentation layers.

It reflects the latest corrected implementation for:
- typed error handling (exception -> failure mapping)
- admin-only endpoint behavior (401 Unauthorized)
- list response pagination shape from OpenAPI (`pagination` object)
- role-aware presentation behavior (user read-only vs admin full actions)

---

## 1) Feature Structure (Domain + Data + Presentation)

```
lib/features/<feature>/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
  ├── bloc/
  ├── screens/
  └── widgets/
```

Direction is always: Presentation -> Domain -> Data.

---

## 2) Domain Entities

Use the right base type for each API response shape.

### Audit-trail entities

For records that include `id`, `guid`, `createdOn`, `updatedOn`, etc., extend `BaseEntity`.

```dart
class ProjectEntity extends BaseEntity {
  final String name;
  final String description;

  const ProjectEntity({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required this.name,
    required this.description,
  });
}
```

### Summary entities

For lightweight list items (for example `ProjectUserSummaryResponse`), use `Equatable` directly.

```dart
class ProjectUserSummaryEntity extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  const ProjectUserSummaryEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, email];
}
```

### Paginated list entities

All list endpoints with pagination must extend `BasePaginatedEntity` and use these exact fields:
- `totalCount`
- `pageSize`
- `pageNumber`
- `totalPages`

```dart
class ProjectListEntity extends BasePaginatedEntity {
  final List<ProjectEntity> projects;

  const ProjectListEntity({
    required this.projects,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });
}
```

---

## 3) Domain Repository Contract

Repository methods always return `Future<Either<Failure, T>>`.

```dart
abstract class ProjectRepository {
  Future<Either<Failure, ProjectEntity>> createProject(
      String name, String? description);

  Future<Either<Failure, ProjectEntity>> updateProject(
      int projectId, String newName, String? newDescription);

  Future<Either<Failure, void>> deleteProject(int projectId);

  Future<Either<Failure, ProjectListEntity>> getProjects(
      int? boardId, int? userId, String? name);

  Future<Either<Failure, ProjectUserAccessEntity>> addUserToProject(
      int projectId, int userId);

  Future<Either<Failure, ProjectUserListEntity>> getProjectUsers(
      int projectId);

  Future<Either<Failure, bool>> removeUserFromProject(
      int projectId, int userId);
}
```

---

## 4) Domain Use Cases

One class per operation; pass through to repository.

```dart
class ListProjectUsecase
    implements UseCase<ProjectListEntity, ListProjectParams> {
  final ProjectRepository repository;

  ListProjectUsecase(this.repository);

  @override
  Future<Either<Failure, ProjectListEntity>> call(
      ListProjectParams params) {
    return repository.getProjects(params.boardId, params.userId, params.name);
  }
}
```

For project user listing, return paginated user summary list, not access rows:

```dart
class ListProjectUsers
    implements UseCase<ProjectUserListEntity, ListProjectUsersParams> {
  final ProjectRepository repository;

  ListProjectUsers(this.repository);

  @override
  Future<Either<Failure, ProjectUserListEntity>> call(
      ListProjectUsersParams params) {
    return repository.getProjectUsers(params.projectId);
  }
}
```

---

## 5) Data Models

Models extend their matching domain entities and map JSON exactly as defined by OpenAPI.

### Key pagination rule

List endpoints are not flat. Pagination is nested:

```json
{
  "projects": [...],
  "pagination": {
    "pageNumber": 1,
    "pageSize": 10,
    "totalCount": 42,
    "totalPages": 5
  }
}
```

So model parsing must read from `json['pagination']`.

```dart
factory ProjectListModel.fromJson(Map<String, dynamic> json) {
  final pagination = json['pagination'] as Map<String, dynamic>;

  return ProjectListModel(
    projects: (json['projects'] as List)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalCount: pagination['totalCount'] as int,
    pageSize: pagination['pageSize'] as int,
    pageNumber: pagination['pageNumber'] as int,
    totalPages: pagination['totalPages'] as int,
  );
}
```

Use the same approach for `/api/projects/{projectId}/users`:
- list item model: `ProjectUserSummaryModel`
- paginated wrapper model: `ProjectUserListModel`

---

## 6) Data Source Error Handling (Exceptions)

### Rule

Never leak `DioException` beyond datasource. Catch it and throw typed app exceptions.

### Required mapping for project and project-user endpoints

- `401` -> `UnauthorizedException`
- `404` -> `NotFoundException`
- all other handled API errors -> `ServerException` (include `message` and `errorCode` when available)

```dart
Never _mapException(DioException e, String fallback) {
  final status = e.response?.statusCode;
  if (status == 401) {
    throw UnauthorizedException(message: _detail(e) ?? 'Unauthorized.');
  }
  if (status == 404) {
    throw NotFoundException(message: _detail(e) ?? 'Resource not found.');
  }
  throw ServerException(
    message: _detail(e) ?? fallback,
    errorCode: _errorCode(e),
  );
}
```

### Admin-only behavior

Project and project-user management endpoints are admin-only. A non-admin token returns `401`, so this must surface as `UnauthorizedException` (not generic server error).

### Endpoint notes (OpenAPI-aligned)

- `PATCH /api/projects/{projectId}` for update
- `DELETE /api/projects/{projectId}` returns `204`
- `GET /api/projects/{projectId}/users` returns `{ users, pagination }`

---

## 7) Repository Error Handling (Failures)

Repository translates exceptions to failures and returns `Either`.

```dart
Failure _mapException(Object e) {
  if (e is UnauthorizedException) {
    return UnauthorizedFailure(message: e.message);
  }
  if (e is NotFoundException) {
    return NotFoundFailure(message: e.message);
  }
  if (e is ServerException) {
    return ServerFailure(message: e.message, errorCode: e.errorCode);
  }
  return ServerFailure(message: e.toString());
}
```

For list-fetch with local cache fallback:
- do not fallback on `401`
- fallback only for server-side fetch failures where cached data is valid

```dart
try {
  final remoteProjects = await remoteDataSource.getProjects(...);
  return Right(remoteProjects);
} on UnauthorizedException catch (e) {
  return Left(UnauthorizedFailure(message: e.message));
} on ServerException catch (e) {
  final localProjects = await localDataSource.getCachedProjects();
  if (localProjects.projects.isNotEmpty) return Right(localProjects);
  return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
}
```

---

## 8) Clean Import Rules (for BLoC files)

When implementing presentation BLoC files:
- use `part of '<feature>_bloc.dart';` in event/state files
- keep shared imports in the main bloc file
- expose a single barrel export file (for example `bloc.dart`)

This keeps import noise low and matches the clean-import pattern used in this project.

---

## 9) Presentation Layer Blueprint (Reusable)

Use this as the default approach for all new feature presentation layers.

### 9.1 File layout

```
lib/features/<feature>/presentation/
├── bloc/
│   ├── <feature>_bloc.dart
│   ├── <feature>_event.dart
│   ├── <feature>_state.dart
│   └── bloc.dart
├── screens/
│   └── <feature>_screen.dart
└── widgets/
  └── ... reusable feature widgets
```

### 9.2 Event design

Model events around user intent and endpoint actions:
- load and refresh (`FeatureLoadRequested`)
- selection (`FeatureSelected`) for list/detail flows
- CRUD (`FeatureCreateRequested`, `FeatureUpdateRequested`, `FeatureDeleteRequested`)
- relationship actions for nested resources (for example add/remove users)
- transient UI cleanup event (`FeatureNoticeCleared`)

Guideline: keep events payload-focused and immutable.

### 9.3 State design

Minimum state set:
- `FeatureInitial`
- `FeatureLoading`
- `FeatureLoaded`
- `FeatureError`

Recommended extras in `FeatureLoaded` for complex screens:
- selected entity id
- related nested list data (for example users in selected project)
- `isBusy` flag for in-place action progress
- `notice` string for one-off success/error snackbars

Add an error-type enum to avoid message-string branching in UI.

### 9.4 BLoC responsibilities

BLoC should:
- orchestrate use case calls only (no network/domain logic in UI)
- map `Failure` to user-facing message + typed error enum
- keep role/access checks centralized
- refresh aggregate state after mutating actions

Pattern for mutating actions:
1. Validate permissions.
2. Emit loaded state with `isBusy = true`.
3. Execute use case.
4. On success, reload list/detail snapshot.
5. On failure, emit loaded state with `notice`.

### 9.5 Role-aware access pattern

Use authenticated user context to split flows at load time:
- standard user: load only own records (for projects, pass `userId` filter)
- admin: load full list and enable all mutation events

Enforce access in both layers:
- backend remains source of truth (`401`)
- presentation blocks disallowed actions early for UX clarity

### 9.6 Screen integration pattern

In screen widgets:
- dispatch initial load once (typically in `didChangeDependencies`)
- use `BlocConsumer` when both rendering and side effects (snackbar/navigation) are needed
- render explicit branches for loading, error, empty, and loaded
- convert loaded domain models into UI widget models near the screen boundary

For one-off notices:
- show snackbar in listener
- immediately dispatch `FeatureNoticeCleared` to avoid duplicate toasts on rebuild

### 9.7 DI and app wiring

Always register in this order:
1. `registerFactory` for BLoC
2. `registerLazySingleton` for use cases
3. repository interface to implementation
4. datasource abstractions to implementations

Expose the feature BLoC using `MultiBlocProvider` where the feature screens are mounted.

---

## 10) Projects Presentation Reference

The Projects feature follows this blueprint exactly.

### User flow

- Loads projects with current user id filter.
- Can view project details only.
- Admin-only UI sections are hidden.

### Admin flow

- Can create/update/delete projects.
- Can add/remove users from selected project.
- On project selection, loads project users and binds them to `ProjectInfoCard` admin table.

### Widget binding notes

- `ProjectInfoCard` is role-aware using an `isAdmin` flag.
- `ProjectAdminUser` includes `userId` so remove actions can call the correct endpoint.
- Screen maps `ProjectUserSummaryEntity` -> `ProjectAdminUser` before passing rows to `_buildAdminData` table.

This reference should be copied structurally for future features, changing only entity names, use case calls, and role rules.
