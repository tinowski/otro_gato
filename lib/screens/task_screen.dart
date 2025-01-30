import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirestoreService _firestoreService = FirestoreService();
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

  void _updateTaskStatus(Task task, TaskStatus newStatus) {
    _firestoreService.updateTaskStatus(task, newStatus);
    _loadTasks();
  }

  Color _getTaskColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.willNotDo:
        return Colors.red;
      case TaskStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Add a new task',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Card(
                      color: _getTaskColor(task.status).withOpacity(0.1),
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(task.status.toString().split('.').last),
                        trailing: PopupMenuButton<TaskStatus>(
                          onSelected: (TaskStatus result) {
                            _updateTaskStatus(task, result);
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<TaskStatus>>[
                            const PopupMenuItem<TaskStatus>(
                              value: TaskStatus.todo,
                              child: Text('To Do'),
                            ),
                            const PopupMenuItem<TaskStatus>(
                              value: TaskStatus.inProgress,
                              child: Text('In Progress'),
                            ),
                            const PopupMenuItem<TaskStatus>(
                              value: TaskStatus.willNotDo,
                              child: Text('Will Not Do'),
                            ),
                            const PopupMenuItem<TaskStatus>(
                              value: TaskStatus.completed,
                              child: Text('Completed'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
