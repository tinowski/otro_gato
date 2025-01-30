import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/app_drawer.dart';
import '../services/firestore_service.dart' as fs;
import '../models/task.dart';
import 'task_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final fs.FirestoreService _firestoreService = fs.FirestoreService();
  List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await _firestoreService.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      _firestoreService.addTask(_taskController.text);
      _taskController.clear();
      _loadTasks();
    }
  }

  void _updateTaskStatus(Task task, fs.TaskStatus newStatus) async {
    await _firestoreService.updateTaskStatus(task, newStatus);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildDashboardContent(
                context, state.userId, state.username);
          } else {
            return Center(
              child: Text('You are not authenticated. Please log in.'),
            );
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, String userId, String username) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 24),
            _buildSummaryCard(),
            SizedBox(height: 24),
            _buildChartCard(),
            SizedBox(height: 24),
            _buildTaskList(),
            SizedBox(height: 24),
            _buildNotificationsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('This Week', '32h 45m'),
                _buildSummaryItem('This Month', '140h 30m'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            )),
      ],
    );
  }

  Widget _buildChartCard() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Work Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 5),
                        FlSpot(2, 4),
                        FlSpot(3, 7),
                        FlSpot(4, 6),
                        FlSpot(5, 8),
                        FlSpot(6, 5),
                      ],
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Task>>(
              future: _firestoreService.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No tasks found',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)));
                } else {
                  final tasks = snapshot.data!;
                  return Column(
                    children: tasks
                        .take(5)
                        .map((task) => ListTile(
                              title: Text(task.title ?? 'Untitled Task',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                              subtitle: Text(
                                  task.status.toString().split('.').last,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7))),
                              trailing: PopupMenuButton<fs.TaskStatus>(
                                onSelected: (fs.TaskStatus result) {
                                  _updateTaskStatus(task, result);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<fs.TaskStatus>>[
                                  const PopupMenuItem<fs.TaskStatus>(
                                    value: fs.TaskStatus.todo,
                                    child: Text('To Do'),
                                  ),
                                  const PopupMenuItem<fs.TaskStatus>(
                                    value: fs.TaskStatus.inProgress,
                                    child: Text('In Progress'),
                                  ),
                                  const PopupMenuItem<fs.TaskStatus>(
                                    value: fs.TaskStatus.willNotDo,
                                    child: Text('Will Not Do'),
                                  ),
                                  const PopupMenuItem<fs.TaskStatus>(
                                    value: fs.TaskStatus.completed,
                                    child: Text('Completed'),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('View All Tasks'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TaskScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            _buildNotificationItem(
                'New project assigned: Mobile App Redesign', '2 hours ago'),
            _buildNotificationItem(
                'Team meeting scheduled for tomorrow', '5 hours ago'),
            _buildNotificationItem(
                'Reminder: Submit weekly report', '1 day ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String message, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications,
              size: 18, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 4),
                Text(time,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
