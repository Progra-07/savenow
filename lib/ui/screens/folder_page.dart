// lib/ui/screens/folder_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for Supabase.instance.client
import '../../models/folder.dart'; // Corrected path
import '../../models/bookmark.dart'; // Corrected path
import '../../providers/bookmark_provider.dart'; // Corrected path

class FolderPage extends StatefulWidget {
  final Folder folder;
  FolderPage({required this.folder});

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Bookmark>>(
              future: bookmarkProvider.getBookmarks(widget.folder.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                List<Bookmark> bookmarks = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    Bookmark bookmark = bookmarks[index];
                    return ListTile(
                      title: Text(bookmark.title),
                      subtitle: _isImage(bookmark.url)
                          ? Image.network(
                              bookmark.url,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            )
                          : Text(bookmark.url),
                      onTap: () {
                        // Implement bookmark opening logic
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () async {
                    final pickedFile = await _pickFile();
                    setState(() {
                      _selectedFile = pickedFile;
                    });
                  },
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    _showUrlDialog(context);
                  },
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  child: Icon(Icons.send),
                  onPressed: () async {
                    if (_selectedFile != null) {
                      final downloadUrl = await _uploadFile(_selectedFile!);
                      _createBookmark(downloadUrl);
                    } else if (_urlController.text.isNotEmpty) {
                      _createBookmark(_urlController.text);
                    }
                    _clearFields();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isImage(String url) {
    final ext = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(); // result can be null
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<String> _uploadFile(File file) async {
    try {
      final fileExtension = file.path.split('.').last;
      final filePath =
          'bookmarks/${widget.folder.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await Supabase.instance.client.storage
          .from(
              'bookmark_images') // Ensure this matches your Supabase bucket name
          .upload(filePath, file); // Corrected: Positional arguments

      final publicUrl = Supabase.instance.client.storage
          .from('bookmark_images')
          .getPublicUrl(filePath); // Corrected: Positional argument
      return publicUrl;
    } catch (e) {
      print('File upload error: $e'); // It's good to log the specific error
      throw Exception('File upload failed: $e');
    }
  }

  void _createBookmark(String url) {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a title for the bookmark.')),
      );
      return;
    }
    Provider.of<BookmarkProvider>(context, listen: false)
        .createBookmark(widget.folder.id, _titleController.text, url);
  }

  void _clearFields() {
    _titleController.clear();
    _urlController.clear();
    setState(() {
      _selectedFile = null;
    });
  }

  void _showUrlDialog(BuildContext context) {
    // Ensure _urlController is cleared before showing dialog if it's reused
    _urlController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add URL'),
        content: TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'Enter URL',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (_urlController.text.isNotEmpty) {
                Navigator.of(context)
                    .pop(); // Pop before calling createBookmark
                _createBookmark(_urlController.text);
                _clearFields(); // Clear fields after successful submission
              } else {
                // Optionally, show a small validation message within the dialog
              }
            },
          ),
        ],
      ),
    );
  }
}
