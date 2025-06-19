// lib/ui/screens/create_folder_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';

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
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (pickedFile != null) {
      setState(() {
        _folderLogo = File(pickedFile.files.single.path!);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Folder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _folderLogo != null ? FileImage(_folderLogo!) : null,
                  child: _folderLogo == null
                      ? Icon(Icons.add_a_photo, size: 35)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Folder Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a folder name' : null,
                onSaved: (value) => _folderName = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Folder Details'),
                onSaved: (value) => _folderDetails = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _createFolder(context),
                child: Text('Create Folder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
