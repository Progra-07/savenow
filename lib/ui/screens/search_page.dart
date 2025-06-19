// lib/ui/screens/search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bookmark.dart'; // Corrected path
import '../../providers/bookmark_provider.dart'; // Corrected path

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search bookmarks...',
            hintStyle: TextStyle(
                color: Colors.white70), // Added hintStyle for better visibility
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          autofocus: true, // Added autofocus
        ),
        backgroundColor: Colors.orange,
      ),
      body: searchQuery.isEmpty // Show a message if search query is empty
          ? Center(child: Text('Enter a query to search for bookmarks.'))
          : FutureBuilder<List<Bookmark>>(
              future: bookmarkProvider.searchBookmarks(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    searchQuery.isNotEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                List<Bookmark> bookmarks = snapshot.data ?? [];
                if (bookmarks.isEmpty && searchQuery.isNotEmpty) {
                  return Center(
                      child: Text('No bookmarks found for "$searchQuery".'));
                }
                return ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    Bookmark bookmark = bookmarks[index];
                    return ListTile(
                      title: Text(bookmark.title),
                      subtitle: Text(bookmark.url),
                      onTap: () {
                        // Add bookmark navigation logic here, e.g., using url_launcher
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
