import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/folder.dart';
import '../models/bookmark.dart';

class BookmarkProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all folders from Supabase
  Future<List<Folder>> getFolders() async {
    try {
      final response = await _supabase.from('folders').select();
      return response.map((row) => Folder.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch folders: $e');
    }
  }

  // Create a new folder in Supabase
  Future<void> createFolder(String name, String details, File? logo) async {
    try {
      String? logoUrl;
      if (logo != null) {
        // Upload logo to Supabase Storage
        final file = await _supabase.storage
            .from('folder_logos')
            .upload('logos/${DateTime.now().millisecondsSinceEpoch}', logo);
        logoUrl =
            await _supabase.storage.from('folder_logos').getPublicUrl(file);
      }

      await _supabase.from('folders').insert({
        'name': name,
        'details': details,
        'logo_url': logoUrl,
        'bookmark_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Folder creation failed: $e');
    }
  }

  // Get bookmarks in a specific folder
  Future<List<Bookmark>> getBookmarks(String folderId) async {
    try {
      final response =
          await _supabase.from('bookmarks').select().eq('folder_id', folderId);
      return response.map((row) => Bookmark.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookmarks: $e');
    }
  }

  // Search bookmarks by title across all folders
  Future<List<Bookmark>> searchBookmarks(String query) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select()
          .or('title.ilike.%${query}%');
      return response.map((row) => Bookmark.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // Create a new bookmark in a folder
  Future<void> createBookmark(String folderId, String title, String url) async {
    try {
      await _supabase.from('bookmarks').insert({
        'title': title,
        'url': url,
        'folder_id': folderId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update folder's bookmark count
      await _supabase
          .rpc('increment_bookmark_count', params: {'folder_id': folderId});

      notifyListeners();
    } catch (e) {
      throw Exception('Bookmark creation failed: $e');
    }
  }

  // Upload a file to Supabase Storage (for bookmarks)
  Future<String> uploadFile(File file, String folderId) async {
    try {
      final path =
          'bookmarks/$folderId/${DateTime.now().millisecondsSinceEpoch}';
      final fileResponse =
          await _supabase.storage.from('bookmark_images').upload(path, file);
      return await _supabase.storage
          .from('bookmark_images')
          .getPublicUrl(fileResponse);
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
