// lib/ui/screens/folder_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/folder.dart';
import '../models/bookmark.dart';
import '../providers/bookmark_provider.dart';

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
    final pickedFile = await FilePicker.platform.pickFiles();
    return pickedFile != null ? File(pickedFile.files.single.path!) : null;
  }

  Future<String> _uploadFile(File file) async {
    try {
      final path =
          'bookmarks/${widget.folder.id}/${DateTime.now().millisecondsSinceEpoch}';
      final res = await Supabase.instance.client.storage
          .from(
              'bookmark_images') // Ensure this matches your Supabase bucket name
          .upload(file: file.path, path: path);
      final urlResponse = await Supabase.instance.client.storage
          .from('bookmark_images')
          .getPublicUrl(path: res.path);
      return urlResponse.url;
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  void _createBookmark(String url) {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add URL'),
        content: TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'Enter URL',
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              Navigator.of(context).pop();
              _createBookmark(_urlController.text);
              _clearFields();
            },
          ),
        ],
      ),
    );
  }
}
