import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

enum TaskStatus { todo, inProgress, willNotDo, completed }

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveTimeEntry(
      DateTime date, String type, DateTime timestamp) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('timeEntries').add({
        'userId': user.uid,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'type': type,
        'timestamp': Timestamp.fromDate(timestamp),
      });
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<void> saveTotalHours(DateTime date, double totalHours) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('dailyHours').add({
        'userId': user.uid,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'totalHours': totalHours,
      });
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Stream<QuerySnapshot> getTimeEntriesForDay(DateTime date) {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('timeEntries')
          .where('userId', isEqualTo: user.uid)
          .where('date',
              isEqualTo:
                  Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .snapshots();
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<QuerySnapshot> getAllTimeEntries() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firestore
          .collection('timeEntries')
          .where('userId', isEqualTo: user.uid)
          .get();
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<List<Task>> getTasks() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .get();
      return snapshot.docs
          .map((doc) => Task(
                id: doc.id,
                title: doc['title'],
                status: TaskStatus.values[doc['status']],
              ))
          .toList();
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<void> addTask(String title) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('tasks').add({
        'userId': user.uid,
        'title': title,
        'status': TaskStatus.todo.index,
      });
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<void> updateTaskStatus(Task task, TaskStatus newStatus) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('tasks').doc(task.id).update({
        'status': newStatus.index,
      });
    } else {
      throw Exception('No authenticated user found');
    }
  }
}
