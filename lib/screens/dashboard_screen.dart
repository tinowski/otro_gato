import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: AppDrawer(),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Center(
              child: Text('Welcome to the Dashboard!'),
            );
          } else {
            return Center(
              child: Text('You are not authenticated. Please log in.'),
            );
          }
        },
      ),
    );
  }
}
