// lib/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      // Implement login logic
    });

    on<SignUpRequested>((event, emit) async {
      // Implement sign up logic
    });

    on<LogoutRequested>((event, emit) async {
      // Implement logout logic
    });
  }
}
