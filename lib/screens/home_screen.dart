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
            return _buildAuthenticatedContent(context, state.userId);
          } else if (state is AuthError) {
            return _buildErrorContent(context, state.message);
          } else {
            return _buildLoadingContent();
          }
        },
      ),
    );
  }

  Widget _buildAuthenticatedContent(BuildContext context, String userId) {
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
            'User ID: $userId',
            style: Theme.of(context).textTheme.titleSmall,
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
  }

  Widget _buildErrorContent(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'An error occurred',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Retry'),
            onPressed: () {
              // Trigger a refresh or re-authentication
              context.read<AuthBloc>().add(LoginRequested('', ''));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
