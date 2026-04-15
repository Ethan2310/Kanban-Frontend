# ThinkNinjas Frontend Roadmap (Flutter + BLoC)

## Purpose

This document is the implementation roadmap for building the ThinkNinjas Tech Challenge frontend.

It is intentionally project-focused and architecture-driven:

- Project scope is derived from the backend schema.
- Frontend architecture follows the BLoC guidelines from the reference index.md (events, states, BLoC classes, consuming widgets, and unidirectional flow).
- Each roadmap step maps to those architecture rules.

## Scope Inputs

### Product Scope From Backend Schema

The backend schema defines a Kanban platform with:

- Authentication and user roles (`Users`, `Role`, `IsVerified`)
- Projects (`Projects`)
- Boards (`Boards`, `ProjectBoards`)
- Status master data (`Statuses`)
- Board columns (`Lists`)
- Tasks lifecycle and ordering (`Tasks`, `OrderIndex`, `Priority`, `DueDate`)
- Access control (`UserProjectAccess`)
- Status audit trail (`TaskStatusHistory`)

### Architecture Rules From index.md

The frontend must enforce:

- Immutable event classes and immutable state classes
- Sealed base classes for events and states
- State base extending Equatable
- Deterministic BLoCs with no hidden mutable data that changes outcomes
- UI-driven BLoC-to-BLoC communication (listener pattern)
- Clear injection via `BlocProvider` / `MultiBlocProvider`

## Target Feature Modules

1. Auth
2. Projects
3. Boards
4. Lists (columns)
5. Tasks
6. Assignment and access views
7. Status history timeline
8. Shared app shell (navigation, failures, loading)

## Recommended Frontend Structure

```text
lib/
  app/
    app.dart
    router/
    di/
  core/
    network/
    error/
    ui/
    utils/
  features/
    auth/
      domain/
      data/
      presentation/
    projects/
      domain/
      data/
      presentation/
    boards/
      domain/
      data/
      presentation/
    lists/
      domain/
      data/
      presentation/
    tasks/
      domain/
      data/
      presentation/
```

Per feature:

```text
feature/
  domain/
    entities/
    repositories/
    usecases/
  data/
    models/
    datasources/
    repositories/
  presentation/
    bloc/
    screens/
    widgets/
```

## Roadmap By Phase

## Phase 0: Foundation

### Objectives

- Establish app shell, API layer, dependency injection, and architecture standards.

### Tasks

1. Create module layout and route skeleton.
2. Add API client and auth token handling.
3. Add global error mapper.
4. Add BLoC templates (sealed event/state, Equatable state base).
5. Define naming and file conventions.

### Architecture Mapping (index.md)

- BLoC injection pattern is established early via app-level providers.
- Events/states are immutable and sealed from the first feature onward.

### Exit Criteria

- New feature scaffolding is consistent and repeatable.
- Error and auth flow are testable in isolation.

## Phase 1: Auth and Session

### Objectives

- Implement login, verification flow, logout, and role-aware session state.

### Tasks

1. Build `AuthBloc`.
2. Implement login screen and validation.
3. Persist and hydrate session.
4. Route based on authenticated, unauthenticated, and unverified states.
5. Add role-aware navigation guards.

### Suggested Event Set

- `AppStarted`
- `LoginSubmitted`
- `LogoutRequested`
- `SessionRestored`

### Suggested State Set

- `AuthInitial`
- `AuthLoading`
- `Authenticated`
- `Unauthenticated`
- `UnverifiedAccount`
- `AuthFailure`

### Architecture Mapping (index.md)

- States model complete UI conditions.
- Widget keeps only UI-local mutable state (for example form controllers).

### Exit Criteria

- Session survives restart.
- Role and verification state correctly drive visible routes.

## Phase 2: Projects and Boards Discovery

### Objectives

- Show only authorized projects and allow board entry.

### Tasks

1. Build `ProjectsBloc`.
2. Build project listing screen with loading, empty, and failure branches.
3. Load boards for selected project using `ProjectBoards` mapping.
4. Add admin-only project access management views.

### Suggested Event Set

- `LoadProjects`
- `RefreshProjects`
- `ProjectSelected`

### Suggested State Set

- `ProjectsInitial`
- `ProjectsLoading`
- `ProjectsLoaded`
- `ProjectsEmpty`
- `ProjectsFailure`

### Architecture Mapping (index.md)

- Prefer explicit empty state where UX differs from generic loaded state.
- Keep events payload-focused and minimal.

### Exit Criteria

- User sees only projects they can access.
- Selecting a project transitions into board flow successfully.

## Phase 3: Board Workspace and Lists

### Objectives

- Render board workspace and lists in board-scoped order.

### Tasks

1. Build `BoardBloc` for board context.
2. Build `ListsBloc` for list retrieval and reordering.
3. Render lists ordered by `OrderIndex` scoped to `BoardId`.
4. Add list reorder interaction and persistence.

### Architecture Mapping (index.md)

- BLoC orchestrates event to state only.
- UI reads state and emits user intent events.

### Exit Criteria

- Board and columns render correctly after refresh.
- List reordering remains stable across reloads.

## Phase 4: Task Lifecycle (Core)

### Objectives

- Implement task CRUD, assignment, movement, and ordering.

### Critical Schema Rule

When moving a task between lists, update `ListId` and `StatusId` together.

### Tasks

1. Build `TasksBloc` for task list and mutations.
2. Add task creation and edit UI.
3. Implement drag/drop between lists.
4. Keep task order by `OrderIndex` scoped to `ListId`.
5. Support assignment, priority, due date, and description.

### Suggested Event Set

- `LoadTasksForBoard`
- `TaskCreated`
- `TaskUpdated`
- `TaskMovedBetweenLists`
- `TaskReorderedWithinList`

### Suggested State Set

- `TasksInitial`
- `TasksLoading`
- `TasksLoaded`
- `TasksMutationInProgress`
- `TasksFailure`

### Architecture Mapping (index.md)

- Data-driven events for all mutations.
- Immutable state evolution via `copyWith` where needed.

### Exit Criteria

- Task movement is correct and durable after page reload.
- No task duplication, gaps, or order drift.

## Phase 5: Status Master Data (Admin)

### Objectives

- Enable admin management of global statuses and integrate status metadata in UI.

### Tasks

1. Build `StatusesBloc`.
2. Add status management pages (admin only).
3. Apply status labels/colors in board and task views.
4. Validate list/status consistency in workflows.

### Architecture Mapping (index.md)

- Bounded contexts use separate BLoCs.
- Cross-feature behavior is coordinated in UI listeners, not direct bloc-to-bloc coupling.

### Exit Criteria

- Status changes are reflected correctly in board/list/task views.
- Non-admin cannot access status write actions.

## Phase 6: Task Status History

### Objectives

- Display append-only status timeline from `TaskStatusHistory`.

### Tasks

1. Build `TaskHistoryBloc`.
2. Add timeline UI in task details view.
3. Show from-status, to-status, changed-by, and timestamp.
4. Trigger history refresh after successful task status mutation.

### Architecture Mapping (index.md)

- BLoC-to-BLoC communication via UI listener pattern:
  - `TasksBloc` emits successful movement state
  - UI listener dispatches refresh event to `TaskHistoryBloc`

### Exit Criteria

- Timeline updates after each status change.
- History flow remains unidirectional and decoupled.

## Phase 7: Hardening and UX Consistency

### Objectives

- Stabilize quality, consistency, and performance across all modules.

### Tasks

1. Standardize loading, empty, and failure components.
2. Improve optimistic update rollback handling.
3. Add pagination/virtualization for large boards if needed.
4. Add retry paths and robust error surfaces.
5. Add instrumentation for key user interactions.

### Architecture Mapping (index.md)

- Every major UI branch must be represented by explicit state.
- Widgets remain declarative and event-driven.

### Exit Criteria

- No unhandled state branches in production screens.
- Consistent UX across features.

## API Mapping Checklist (From Schema)

1. Auth and session endpoints
2. Projects (user-scoped)
3. Boards by project
4. Lists by board + list ordering
5. Tasks CRUD + move + reorder
6. Statuses read (all users) and write (admin only)
7. UserProjectAccess management (admin)
8. TaskStatusHistory retrieval

## Engineering Rules (Non-Negotiable)

1. Events are immutable and intent-driven.
2. States are immutable, Equatable, and exhaustive.
3. BLoCs are deterministic and orchestration-focused.
4. Widgets dispatch events and render states only.
5. No direct repository usage from UI.
6. Cross-BLoC effects happen through UI listeners.

## Recommended Implementation Order

1. Foundation
2. Auth
3. Projects and board discovery
4. Lists and board workspace
5. Task lifecycle
6. Status admin
7. Task history timeline
8. Hardening

## Definition Of Done (Per Module)

1. Event/state coverage is complete.
2. Loading/empty/success/failure are all handled.
3. Unit tests exist for major event->state transitions.
4. Widget tests cover key rendering branches.
5. Integration path exists for one happy and one failure flow.

## Main Risks and Mitigations

1. State growth complexity
- Mitigation: split BLoCs per bounded context and keep states explicit.
2. Ordering bugs (`OrderIndex` scope rules)
- Mitigation: centralize reorder logic and add targeted tests.
3. Coupling between modules
- Mitigation: enforce listener-based communication only.
4. Role/access drift
- Mitigation: route guards + API layer checks + role-aware tests.

## Assumptions

1. ThinkNinjas frontend is a Flutter Kanban client aligned with the attached schema.
2. Backend APIs expose all required entities and operations.
3. Soft-delete filtering is primarily backend enforced, with frontend handling inactive-safe rendering.

If the challenge includes additional capabilities (for example notifications, comments, attachments, or realtime sync), add them as extra phases while preserving the same BLoC architecture constraints.
