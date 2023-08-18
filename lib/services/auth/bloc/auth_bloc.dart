import 'package:bloc/bloc.dart';
import 'package:first_app/services/auth/auth_provider.dart';
import 'package:first_app/services/auth/bloc/auth_event.dart';
import 'package:first_app/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          isLoading: false,
          exception: null,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStatePendingVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(isLoading: true, exception: null));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(isLoading: false, exception: null));
          emit(const AuthStatePendingVerification());
        } else {
          emit(const AuthStateLoggedOut(isLoading: false, exception: null));
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          isLoading: false,
          exception: e,
        ));
      }
    });

    // log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(isLoading: true, exception: null));
        await provider.logOut();
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e));
      }
    });

    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    // register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStatePendingVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    // go to Register View
    on<AuthEventGoRegister>((event, emit) {
      emit(const AuthStateRegistering(null));
    });
  }
}
