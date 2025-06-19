// lib/ui/screens/create_folder_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/bookmark_provider.dart'; // Corrected path

class CreateFolderPage extends StatefulWidget {
  @override
  _CreateFolderPageState createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final _formKey = GlobalKey<FormState>();
  String _folderName = '';
  String _folderDetails = '';
  File? _folderLogo;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      // Renamed for clarity
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      // Check if path is not null
      setState(() {
        _folderLogo = File(result.files.single.path!);
      });
    }
  }

  void _createFolder(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Use provider to create folder with Supabase
      Provider.of<BookmarkProvider>(context, listen: false)
          .createFolder(_folderName, _folderDetails, _folderLogo);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make the page scrollable to avoid overflow when keyboard appears
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Folder'),
        backgroundColor: Colors.orange, // Consistent AppBar color
      ),
      body: SingleChildScrollView(
        // Added SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50, // Increased radius
                  backgroundColor:
                      Colors.grey[200], // Background color for avatar
                  backgroundImage:
                      _folderLogo != null ? FileImage(_folderLogo!) : null,
                  child: _folderLogo == null
                      ? Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey[800]) // Icon color
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Folder Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a folder name' : null,
                onSaved: (value) => _folderName = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Folder Details (Optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSaved: (value) =>
                    _folderDetails = value ?? '', // Handle null value
              ),
              SizedBox(height: 30), // Increased spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Consistent button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () => _createFolder(context),
                child: Text('Create Folder',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
