import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      onEditingComplete: () =>
                          setState(() => _autovalidate = true),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      validator: _validatePassword,
                      onEditingComplete: () =>
                          setState(() => _autovalidate = true),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text(
                          state is AuthLoading ? 'Logging in...' : 'Login'),
                      onPressed: state is AuthLoading ? null : _attemptLogin,
                    ),
                    TextButton(
                      child: Text('Don\'t have an account? Sign Up'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _attemptLogin() {
    setState(() => _autovalidate = true);
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              _emailController.text,
              _passwordController.text,
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors in the form.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
