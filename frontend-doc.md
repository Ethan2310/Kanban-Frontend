# Frontend-Architecture

# Flutter BLOC Architecture

![](assets/xvajec9YIH3_evjwCdB5JEMGk9JjV_5u5Zde2wRO-vs=.webp)

Resources used for this arhitecture: 

[Flutter BLoC — Handbook for scalable mobile applications — Part 1](https://medium.com/@sm.mbamba/flutter-bloc-handbook-for-scalable-mobile-applications-697d64018eb5)

[Flutter BLoC: Handbook for scalable mobile applications — Part 2](https://medium.com/@sm.mbamba/flutter-bloc-handbook-for-scalable-mobile-applications-part-2-815dcd12930c?postPublishedType=initial)

## Understanding BLOC

* Flutter BLOC is a state management architecture and library for Flutter applications that implement the BLoC ( Business Logic Component ) pattern.
* helps separate presentation from business logic
* Uses streams to manage state changes - allowing widgets to react to events and update their UI efficiently
* Essential components:
  * events
  * states
  * BLoC classes
  * Consuming Widgets



## Events

Events represent user actions or external occurences that trigger state changes in the BLoC implemenation.

Two types:

* Dataless event
* Data-driven events

Dataless -> plain enum

Anything else -> immutable classes - all events extend a sealed base abstract class

Immutable to ensure they are only created in tesponse to user interactions and never modified afterwards.

BLoC class all have subclasses of the same base class which will be used as the event type of your class declaration

To ensure every event is handled -> use a sealed base class for your events.

Allows us to use a switch statement on event types and compiler will enforce exhaustiveness. DONOT use a defaut case unless there is a valid usecase.



## States

States are UI states that represent the current application data or status that needs to be displayed in the current UI view.

Two categories:

* Exhaustive value states -> binary states such as verified and not verified for a user login
* Data-carrying states -> requires user identifier 

States should be immutable and extend a sealed abstract class. This base class must extend Equatable. Being immutable gurantees they are created only in mapping of the data received for domain and data entries and never modified afterwards.

Important to consider a copyWIth in all states when the need arises to create a new state from an existing one.

State definitions should comprehensively represent all possible UI conditions and each encapsulated within a single state class.

States may carry data or not - each state should include the event that triggered it. This will prevent state bloat - as the originating trigger event can be used to determine the UI vs created two different states.

Since our states extend a base state - widgets can have a unique entry point to the handling of all the states subclassing that event. To ensure every syaye is handled, use a sealed base class for your states - allws to use a switch on event types and compiler will enforce exhaustiveness. Similar to events.

#### Dealing with a scenario: EmptyState vs Loaded State

We have two options here:

* FeatureLoaded + isEmpty
* FeatureLoaded + FeatureEmpty

Using a dedicated FeatureEmpty advantages -> seperation of concerns, extensibility and consicion

PROBLEM: This does not gurantee that FeatureLoaded contains data. The list can still be empty and no compilation error will occur. 

SOLUTION: Perform this check before creating the FeatureLoaded state - constructor must be non-const.

COST: Loss of immutability and performance decrease as dart cannot compule non const at compile time.



## BLoC Class

The BLoC class manages the business logic, processes events and emits states



BLoC classes need to extend the BLoC base class

Events are registered using the method `on`provided by the BLoC base class

Deprive the BLoC classes of any domain logic. The pattern we will use: define StateCreator entities responsible for implementing the bussines logic -> state creators will then call data and domain entities. 

Once a state is created , the `emit` method is used to propogate it to the various subscribers ( stateful widgets ) of the BLoC entity 

The BLoC class in Flutters library carries a state property defined by its base class - do not introduce additional stored properties in the BLoC that could influence the outcome of incoming events. Why? -> opacity to call sites, risk of side effects, complexity and maintainability

The result of processing an event should depend only on:

* The event details
* The previous state and not any other stored property or hidden context

TO keep BLoC methods pure and deterministic for better maintainability and scalability:

* Use only the previous state and the incoming event to compute the next state
* Avoid introducing hidden mutable properties



## File import nightmare

BLoC pattern in Flutter promotes seperation of concerns -> splits logic into multiple files: bloc, event and state. This can often lead to import bloat. Solution -> unifying the imports with the approach below.



Using `part of` directive

* allows related files to be compiled as part of the main BLoC file
* by declaring part of `feature_bloc.dart` in `feature_event.dart` and `feature_state.dart` these files share the same library scope as the BLoC file. 
* reduces redundant imports and ensures private members can be accessed across these files without exposing them globally.

Module Export File:

* to futher simplify imports create a module export file ( eg `feature_blocs.dart` ) that exports all relevant BLoC components: `export 'feature/feature_bloc.dart` 
* consumers can then import a single file instead of multiple ones improving clarity and reducing boilerplate.



## BLoC Injection in Widgets

To make BLoC accessible to widgets - it is injected into the widget tree using `BlocProvider` 

This allows descendant widgets to consume the BLoC without manual passing of instances.

#### Two Ways Widgets consume a BLoC

Owning the BLoC - widget creates and manages its own BLoC instance - typically uses BlocProvider in its build method.

* widget controls lifecycle of BLoC
* when widget is disposed of - BLoC automatically closes



Widget not owning the BLoC - BLoC is created elsewhere and the widget only needs to consume it -> use `BlocProvider.value`

* approach prevents creating a new instance 
* ideal for passing BLoC down the tree without rebuilding them

When multiple BLoCs are needed in the same subtree:

```dart
void main() {
    runApp(
        MultiBlocProvider(
            providers: [
              BlocProvider<TodoListBloc>(
                create: (context) => TodoListBloc(),
              ),
              BlocProvider<ActiveTodoCountBloc>(
                create: (context) => ActiveTodoCountBloc(
                0,
                context.read<TodoListBloc>(),
               ),
            ),
            ],
            child: MyApp(),
       ),
     );
}
```

Stateless widge consumes a BLoC: yes -> BLoC instance provided via the widget tree not stored in the widget itself. Using `BlocBuilder` or `BlocConsumer` inside a stateless widget works perfectly.



Since Flutter UI is declarative, a BLoC instance can be used to drive non-mutable state that would be loaded based on the BLoCs current state. Stateless widgets rely on external state ( from BLoC ) rather than internal mutable state.



Summary

* Use StatelessWidgets when the BLoC is injected via `BlocProvider` higher in the tree
* Use StatefulWidget when the widget needs to create and dispose of its own BLoC instance



## BLoC to BLoC communication

#### Using BLoC listeners - Lift State up

Unidirectional Data Flow: AuthBloc -> UI -> ProfileBloc

But never: AuthBloc -> ProfileBloc

Flow:

* AuthBloc emits Authenticated(UserID)
* UI ( BlocListener ) hears the new state
* UI dispatches `LoadUserProfile(userID)` to ProfileBloc
* ProfileBloc calls data access entities
* UI reacts to ProfileBloc state

How it looks:

* wrap widget tree with BlocListener
* Provide the BLoC type and a callback in listener that adds an event to the listening BLoC
* UI updates to be based on events emitted by both BLoC entities 

Example:

```dart
// home_page.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is Authenticated || current is Unauthenticated,
      listener: (context, state) {
        if (state is Authenticated) {
          // BLOC to BLOC communcation
          context.read<ProfileBloc>().add(
                LoadUserProfile(state.userId),
              );
        }

        if (state is Unauthenticated) {
          // Optionally reset profile state
          context.read<ProfileBloc>().add(ResetProfile());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const CircularProgressIndicator();
            } else if (state is ProfileLoaded) {
              return Text("Hello, ${state.user.name}");
            } else {
              return const Text("No profile loaded");
            }
          },
        ),
      ),
    );
  }
}
```

```dart
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SomeType dataAccessEntity;

  ProfileBloc(this.dataAccessEntity) : super(ProfileInitial()) {
    on<LoadUserProfile>((event, emit) async {
      final user = await dataAccessEntity.fetchUser(event.userId);
      emit(ProfileLoaded(user));
    });
  }
}
```
