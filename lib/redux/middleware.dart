import 'package:podcustard/services/itunes_service.dart';
import 'package:redux/redux.dart';
import 'package:podcustard/models/actions.dart';
import 'package:podcustard/models/app_state.dart';
import 'package:podcustard/services/auth_service.dart';

/// Middleware is used for a variety of things:
/// - Logging
/// - Async calls (database, network)
/// - Calling to system frameworks
///
/// These are performed when actions are dispatched to the Store
///
/// The output of an action can perform another action using the [NextDispatcher]
///
List<Middleware<AppState>> createMiddleware(
    AuthService authService, ItunesService itunesService) {
  return [
    TypedMiddleware<AppState, ObserveAuthState>(
      _observeAuthState(authService),
    ),
    TypedMiddleware<AppState, SigninWithGoogle>(
      _signinWithGoogle(authService),
    ),
    TypedMiddleware<AppState, SigninWithApple>(
      _signinWithApple(authService),
    ),
    TypedMiddleware<AppState, RetrievePodcastSummaries>(
      _retrievePodcastSummaries(itunesService),
    ),
  ];
}

void Function(
        Store<AppState> store, ObserveAuthState action, NextDispatcher next)
    _observeAuthState(AuthService authService) {
  return (Store<AppState> store, ObserveAuthState action,
      NextDispatcher next) async {
    next(action);

    // listen to the stream that emits actions on any auth change
    // and call dispatch on the action
    authService.streamOfStateChanges.listen(store.dispatch);
  };
}

void Function(
        Store<AppState> store, SigninWithGoogle action, NextDispatcher next)
    _signinWithGoogle(AuthService authService) {
  return (Store<AppState> store, SigninWithGoogle action,
      NextDispatcher next) async {
    next(action);

    // signin and listen to the stream and dispatch actions
    authService.googleSignInStream.listen(store.dispatch);
  };
}

void Function(
        Store<AppState> store, SigninWithApple action, NextDispatcher next)
    _signinWithApple(AuthService authService) {
  return (Store<AppState> store, SigninWithApple action,
      NextDispatcher next) async {
    next(action);

    // signin and listen to the stream and dispatch actions
    authService.appleSigninStream.listen(store.dispatch);
  };
}

void Function(Store<AppState> store, RetrievePodcastSummaries action,
        NextDispatcher next)
    _retrievePodcastSummaries(ItunesService itunesService) {
  return (Store<AppState> store, RetrievePodcastSummaries action,
      NextDispatcher next) async {
    next(action);

    // retrieve podcast summaries and dispatch action to store result
    final storeAction =
        await itunesService.retrievePodcastSummaries(query: action.query);
    store.dispatch(storeAction);
  };
}
