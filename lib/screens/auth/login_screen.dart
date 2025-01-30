// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle state changes
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add email and password fields
              ElevatedButton(
                child: Text('Login'),
                onPressed: () {
                  // Dispatch login event
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
