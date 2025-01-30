import '../services/firestore_service.dart' show TaskStatus;

class Task {
  final String id;
  final String title;
  TaskStatus status;

  Task({required this.id, required this.title, this.status = TaskStatus.todo});
}
