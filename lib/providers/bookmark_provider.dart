import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/folder.dart';
import '../models/bookmark.dart';
import '../core/dependencies.dart';
import '../services/bookmark_service.dart'; // Ensure this is imported

class BookmarkProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase
      .instance.client; // Kept for operations not yet in BookmarkService
  final BookmarkService _bookmarkService = ServiceLocator.bookmarkService;

  // Get all folders
  Future<List<Folder>> getFolders() async {
    try {
      // Refactored to use BookmarkService
      return await _bookmarkService.getFolders();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'BookmarkProvider.getFolders');
      throw Exception('Failed to fetch folders: $e');
    }
  }

  // Create a new folder in Supabase
  // This logic remains here for now, as it's not in the provided BookmarkService structure.
  // It could be moved to BookmarkService in a future refactor.
  Future<void> createFolder(String name, String details, File? logo) async {
    try {
      String? logoUrl;
      if (logo != null) {
        final filePath =
            'logos/${DateTime.now().millisecondsSinceEpoch}.${logo.path.split('.').last}';
        await _supabase.storage
            .from(
                'folder_logos') // Make sure this bucket exists and has appropriate policies
            .upload(filePath, logo);
        logoUrl = _supabase.storage.from('folder_logos').getPublicUrl(filePath);
      }

      await _supabase.from('folders').insert({
        'name': name,
        'details': details,
        'logo_url': logoUrl,
        // 'bookmark_count': 0, // Assuming default value in DB or handled by trigger
        // 'user_id': _supabase.auth.currentUser!.id, // Assuming this is handled by RLS or default value
        // 'created_at': DateTime.now().toIso8601String(), // Assuming default value in DB (e.g., now())
      });

      notifyListeners();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'BookmarkProvider.createFolder');
      throw Exception('Folder creation failed: $e');
    }
  }

  // Get bookmarks in a specific folder
  Future<List<Bookmark>> getBookmarks(String folderId) async {
    try {
      // Refactored to use BookmarkService
      return await _bookmarkService.getBookmarksInFolder(folderId);
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'BookmarkProvider.getBookmarks');
      throw Exception('Failed to fetch bookmarks: $e');
    }
  }

  // Search bookmarks by title across all folders
  // This logic remains here for now.
  Future<List<Bookmark>> searchBookmarks(String query) async {
    try {
      final response =
          await _supabase.from('bookmarks').select().or('title.ilike.%$query%');
      // Assuming the response needs mapping if it's not directly List<Map<String, dynamic>>
      // This depends on how Supabase client returns data from .select()
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((row) => Bookmark.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'BookmarkProvider.searchBookmarks');
      throw Exception('Search failed: $e');
    }
  }

  // Create a new bookmark in a folder
  // This logic remains here for now.
  Future<void> createBookmark(String folderId, String title, String url) async {
    try {
      await _supabase.from('bookmarks').insert({
        'title': title,
        'url': url,
        'folder_id': folderId,
        // 'user_id': _supabase.auth.currentUser!.id, // Assuming RLS
        // 'created_at': DateTime.now().toIso8601String(), // Assuming default in DB
      });

      // Update folder's bookmark count - This might be better as a trigger/function in Supabase
      await _supabase
          .rpc('increment_bookmark_count', params: {'p_folder_id': folderId});

      notifyListeners();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'BookmarkProvider.createBookmark');
      throw Exception('Bookmark creation failed: $e');
    }
  }

  // Upload a file to Supabase Storage (for bookmarks)
  // This logic remains here for now.
  Future<String> uploadFile(File file, String folderId) async {
    try {
      // It's good practice to include user_id or folder_id in the path for organization and security policy enforcement
      final path =
          'bookmark_assets/$folderId/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      await _supabase.storage
          .from('bookmark_files')
          .upload(path, file); // Ensure 'bookmark_files' bucket exists
      return _supabase.storage.from('bookmark_files').getPublicUrl(path);
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'BookmarkProvider.uploadFile');
      throw Exception('File upload failed: $e');
    }
  }
}
