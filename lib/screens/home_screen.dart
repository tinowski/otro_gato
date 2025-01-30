import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: AppDrawer(),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('New feature available'),
                      subtitle: Text('Check out our latest update'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('New Task'),
                        onPressed: () {
                          // TODO: Implement new task functionality
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.person),
                        label: Text('Profile'),
                        onPressed: () {
                          // TODO: Navigate to profile screen
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.settings),
                        label: Text('Settings'),
                        onPressed: () {
                          // TODO: Navigate to settings screen
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
