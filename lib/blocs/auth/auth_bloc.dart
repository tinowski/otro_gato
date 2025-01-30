import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        print(
            'Attempting to sign in with email: ${event.email}'); // Add this line
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        print('User signed in: ${userCredential.user?.uid}'); // Add this line

        // Fetch the username from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw Exception('User document not found in Firestore');
        }

        String username = userDoc.get('username') as String;
        print('Username fetched: $username'); // Add this line

        emit(Authenticated(userCredential.user!.uid, username));
      } on FirebaseAuthException catch (e) {
        print(
            'FirebaseAuthException: ${e.code} - ${e.message}'); // Add this line
        emit(AuthError(_getErrorMessage(e)));
      } catch (e) {
        print('Unexpected error: $e'); // Add this line
        emit(AuthError('An unexpected error occurred. Please try again.'));
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

        // Save the username to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': event.username,
          'email': event.email,
        });

        emit(Authenticated(userCredential.user!.uid, event.username));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_getErrorMessage(e)));
      } catch (e) {
        emit(AuthError('An unexpected error occurred. Please try again.'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError('Failed to log out. Please try again.'));
      }
    });
  }

  String _getErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No user found with this email. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'invalid-email':
        return 'The email address is not valid. Please enter a valid email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Please log in or use a different email.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred: ${exception.message}';
    }
  }
}
