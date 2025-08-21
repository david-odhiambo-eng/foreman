import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  CollectionReference get _notesCollection => _firestore
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('notes');

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> get notes => _notes;
  
  int get totalNotesCount => _notes.length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotesProvider() {
    _setupListener();
  }

  void _setupListener() {
    _notesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addNote(String title, String content) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _notesCollection.add({
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(String noteId, String title, String content) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _notesCollection.doc(noteId).update({
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _notesCollection.doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAllNotes() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final querySnapshot = await _notesCollection.get();
      final batch = _firestore.batch();
      
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotes() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final querySnapshot = await _notesCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      _notes = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    
    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      final title = (note['title'] ?? '').toString().toLowerCase();
      final content = (note['content'] ?? '').toString().toLowerCase();
      return title.contains(lowercaseQuery) || content.contains(lowercaseQuery);
    }).toList();
  }

  Map<String, dynamic>? getNoteById(String noteId) {
    try {
      return _notes.firstWhere((note) => note['id'] == noteId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateNoteContent(String noteId, String content) async {
    try {
      await _notesCollection.doc(noteId).update({
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update note content: $e');
    }
  }

  Future<void> updateNoteTitle(String noteId, String title) async {
    try {
      await _notesCollection.doc(noteId).update({
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update note title: $e');
    }
  }

  Future<int> getTotalNotesCount() async {
    try {
      final querySnapshot = await _notesCollection.get();
      return querySnapshot.size;
    } catch (e) {
      throw Exception('Failed to get total notes count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentNotes(int limit) async {
    try {
      final querySnapshot = await _notesCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent notes: $e');
    }
  }

  Future<void> archiveNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).update({
        'archived': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to archive note: $e');
    }
  }

  Future<void> unarchiveNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).update({
        'archived': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unarchive note: $e');
    }
  }

  Future<void> pinNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).update({
        'pinned': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to pin note: $e');
    }
  }

  Future<void> unpinNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).update({
        'pinned': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unpin note: $e');
    }
  }

  // Helper method to check if user has any notes
  bool get hasNotes => _notes.isNotEmpty;

  // Helper method to get pinned notes
  List<Map<String, dynamic>> get pinnedNotes {
    return _notes.where((note) => note['pinned'] == true).toList();
  }

  // Helper method to get archived notes
  List<Map<String, dynamic>> get archivedNotes {
    return _notes.where((note) => note['archived'] == true).toList();
  }

  // Helper method to get active (non-archived) notes
  List<Map<String, dynamic>> get activeNotes {
    return _notes.where((note) => note['archived'] != true).toList();
  }

  // Clear all notes from memory (useful for logout)
  void clearNotes() {
    _notes.clear();
    notifyListeners();
  }

  // Check if a note exists by ID
  bool noteExists(String noteId) {
    return _notes.any((note) => note['id'] == noteId);
  }

  // Get notes created on a specific date
  List<Map<String, dynamic>> getNotesByDate(DateTime date) {
    return _notes.where((note) {
      final createdAt = note['createdAt'] as Timestamp?;
      if (createdAt == null) return false;
      
      final noteDate = createdAt.toDate();
      return noteDate.year == date.year &&
             noteDate.month == date.month &&
             noteDate.day == date.day;
    }).toList();
  }

  // Get notes with specific tag (if you implement tagging)
  List<Map<String, dynamic>> getNotesByTag(String tag) {
    return _notes.where((note) {
      final tags = note['tags'] as List<dynamic>?;
      return tags != null && tags.contains(tag);
    }).toList();
  }
}