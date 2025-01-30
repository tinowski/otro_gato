import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(userCredential.user!.uid));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'An error occurred during login'));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(userCredential.user!.uid));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'An error occurred during sign up'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError('An error occurred during logout'));
      }
    });
  }
}
