import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}
