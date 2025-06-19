import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bookmark.dart'; // Assuming you have these models
import '../models/folder.dart'; // Assuming you have these models

class BookmarkService {
  final SupabaseClient _client = Supabase.instance.client;

  // TODO: Implement actual Supabase table names
  static const String _foldersTable = 'folders';
  static const String _bookmarksTable = 'bookmarks';

  // Example: Get all folders for the current user
  Future<List<Folder>> getFolders() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Directly await the select query. It returns List<Map<String, dynamic>> on success.
      final data =
          await _client.from(_foldersTable).select().eq('user_id', userId)
              as List<dynamic>; // Cast to List<dynamic> for mapping

      // No need to check response.error, PostgrestException will be thrown on error
      return data
          .map((json) => Folder.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      // Catch specific Supabase exception
      print('BookmarkService getFolders PostgrestException: ${e.message}');
      throw Exception('Failed to get folders: ${e.message}');
    } catch (e) {
      print('BookmarkService getFolders general exception: $e');
      rethrow; // Rethrow other exceptions
    }
  }

  // Example: Get bookmarks for a specific folder
  Future<List<Bookmark>> getBookmarksInFolder(String folderId) async {
    try {
      final data = await _client
          .from(_bookmarksTable)
          .select()
          .eq('folder_id', folderId) as List<dynamic>;

      return data
          .map((json) => Bookmark.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      print(
          'BookmarkService getBookmarksInFolder PostgrestException: ${e.message}');
      throw Exception('Failed to get bookmarks in folder: ${e.message}');
    } catch (e) {
      print('BookmarkService getBookmarksInFolder general exception: $e');
      rethrow;
    }
  }

  // Add methods for createFolder, addBookmark, updateBookmark, deleteBookmark etc.
  // Remember to handle errors and user authentication/authorization for each operation.
}
