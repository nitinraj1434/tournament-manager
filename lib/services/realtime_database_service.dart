import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Singleton pattern
  static final RealtimeDatabaseService _instance =
      RealtimeDatabaseService._internal();
  factory RealtimeDatabaseService() => _instance;
  RealtimeDatabaseService._internal();

  DatabaseReference get _rootRef => _db.ref();

  /// Writes data to the specified path. Replaces any existing data at that path.
  Future<void> set(String path, dynamic value) async {
    try {
      await _rootRef.child(path).set(value);
    } catch (e) {
      debugPrint('Error setting data at $path: $e');
      rethrow;
    }
  }

  /// Updates data at the specified path. Only updates the specified child keys.
  Future<void> update(String path, Map<String, Object?> value) async {
    try {
      await _rootRef.child(path).update(value);
    } catch (e) {
      debugPrint('Error updating data at $path: $e');
      rethrow;
    }
  }

  /// Pushes a new child to the specified path with a unique key.
  Future<String?> push(String path, dynamic value) async {
    try {
      final newRef = _rootRef.child(path).push();
      await newRef.set(value);
      return newRef.key;
    } catch (e) {
      debugPrint('Error pushing data to $path: $e');
      rethrow;
    }
  }

  /// Reads data once from the specified path.
  Future<Object?> get(String path) async {
    try {
      final snapshot = await _rootRef.child(path).get();
      if (snapshot.exists) {
        return snapshot.value;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting data from $path: $e');
      rethrow;
    }
  }

  /// Streams data changes at the specified path.
  Stream<DatabaseEvent> stream(String path) {
    return _rootRef.child(path).onValue;
  }

  /// Removes data at the specified path.
  Future<void> remove(String path) async {
    try {
      await _rootRef.child(path).remove();
    } catch (e) {
      debugPrint('Error removing data at $path: $e');
      rethrow;
    }
  }
}
