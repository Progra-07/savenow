// lib/ui/screens/search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../providers/bookmark_provider.dart';

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
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Bookmark>>(
        future: bookmarkProvider.searchBookmarks(searchQuery),
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
                subtitle: Text(bookmark.url),
                onTap: () {
                  // Add bookmark navigation logic here
                },
              );
            },
          );
        },
      ),
    );
  }
}
