import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static late DatabaseReference _database;
  static String? _userId;

  static Future<void> init() async {
    await Firebase.initializeApp();
    _database = FirebaseDatabase.instance.ref();
    _userId = const Uuid().v4(); // Generate unique user ID
  }

  static String get userId => _userId!;

  static DatabaseReference get signalingRef =>
      _database.child('signals/$userId');

  static Future<void> sendSignal({
    required String peerId,
    required Map<String, dynamic> signal,
  }) async {
    await _database.child('signals/$peerId').push().set({
      ...signal,
      'from': userId,
      'timestamp': ServerValue.timestamp,
    });
  }

  static void listenForSignals(Function(Map<String, dynamic>) onSignal) {
    signalingRef.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      onSignal(Map<String, dynamic>.from(data));
      event.snapshot.ref.remove();
    });
  }
}
