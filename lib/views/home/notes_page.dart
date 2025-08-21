import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foreman/models/providers/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';


class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: reusableStyle2().copyWith(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddNoteDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                _buildSearchField(),
                const SizedBox(height: 16),
                
                // Notes Count
                _buildNotesCount(notesProvider),
                const SizedBox(height: 16),
                
                // Notes List
                Expanded(
                  child: _buildNotesList(notesProvider),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Search notes...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildNotesCount(NotesProvider notesProvider) {
    final filteredNotes = _getFilteredNotes(notesProvider.notes);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCountItem('Total Notes', notesProvider.notes.length, Icons.note),
          _buildCountItem('Filtered', filteredNotes.length, Icons.filter_list),
        ],
      ),
    );
  }

  Widget _buildCountItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesList(NotesProvider notesProvider) {
    if (notesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredNotes = _getFilteredNotes(notesProvider.notes);

    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty 
                ? 'Tap + to add your first note'
                : 'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final title = note['title'] ?? 'Untitled';
    final content = note['content'] ?? '';
    final createdAt = note['createdAt'] != null 
        ? (note['createdAt'] as Timestamp).toDate() 
        : DateTime.now();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showEditNoteDialog(context, note),
            onLongPress: () => _showDeleteDialog(context, note),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditNoteDialog(context, note);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, note);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotes(List<Map<String, dynamic>> notes) {
    if (_searchQuery.isEmpty) return notes;
    
    return notes.where((note) {
      final title = (note['title'] ?? '').toString().toLowerCase();
      final content = (note['content'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery) || content.contains(_searchQuery);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddNoteDialog(BuildContext context) {
    _showNoteDialog(context, null);
  }

  void _showEditNoteDialog(BuildContext context, Map<String, dynamic> note) {
    _showNoteDialog(context, note);
  }

  void _showNoteDialog(BuildContext context, Map<String, dynamic>? note) {
    final titleController = TextEditingController(text: note?['title'] ?? '');
    final contentController = TextEditingController(text: note?['content'] ?? '');
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Add New Note' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                try {
                  if (note == null) {
                    await notesProvider.addNote(
                      titleController.text.trim(),
                      contentController.text.trim(),
                    );
                  } else {
                    await notesProvider.updateNote(
                      note['id'],
                      titleController.text.trim(),
                      contentController.text.trim(),
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(note == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> note) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await notesProvider.deleteNote(note['id']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting note: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}