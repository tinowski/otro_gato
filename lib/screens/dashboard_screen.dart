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
            return _buildDashboardContent(context, state.userId);
          } else {
            return Center(
              child: Text('You are not authenticated. Please log in.'),
            );
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, String userId) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Your Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 20),
          Text(
            'User ID: $userId',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 20),
          _buildStatCard('Total Tasks', '12', Icons.task_alt),
          SizedBox(height: 10),
          _buildStatCard('Completed Tasks', '8', Icons.check_circle_outline),
          SizedBox(height: 10),
          _buildStatCard('Pending Tasks', '4', Icons.pending_actions),
          SizedBox(height: 20),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16)),
                SizedBox(height: 5),
                Text(value,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.add_task),
          title: Text('New task added'),
          subtitle: Text('Project X - Design phase'),
          trailing: Text('2h ago'),
        ),
        ListTile(
          leading: Icon(Icons.task_alt),
          title: Text('Task completed'),
          subtitle: Text('Project Y - Development phase'),
          trailing: Text('5h ago'),
        ),
        ListTile(
          leading: Icon(Icons.comment),
          title: Text('New comment'),
          subtitle: Text('On task: Implement user authentication'),
          trailing: Text('1d ago'),
        ),
      ],
    );
  }
}
