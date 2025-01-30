import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/app_drawer.dart';
import '../screens/dashboard_screen.dart';
import '../screens/timesheet_screen.dart';
import '../screens/task_screen.dart';

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
            return _buildAuthenticatedContent(context);
          } else if (state is AuthError) {
            return _buildErrorContent(context, state.message);
          } else {
            return _buildLoadingContent();
          }
        },
      ),
    );
  }

  Widget _buildAuthenticatedContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildQuickActionCard(
                context,
                'Dashboard',
                Icons.dashboard,
                () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => DashboardScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Tasks',
                Icons.list,
                () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TaskScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Timesheet',
                Icons.access_time,
                () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TimesheetScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
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
            style: Theme.of(context).textTheme.bodyLarge,
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
