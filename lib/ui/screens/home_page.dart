// lib/ui/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/folder.dart'; // Corrected path
import '../../providers/auth_provider.dart'; // Corrected path
import '../../providers/bookmark_provider.dart'; // Corrected path
import 'folder_page.dart'; // Corrected path
import 'search_page.dart'; // Corrected path
import 'create_folder_page.dart'; // Corrected path

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // List of pages for navigation
  final List<Widget> _pages = [
    BookmarkListPage(),
    SearchPage(),
    Placeholder(), // Replace with Notifications page
    Placeholder(), // Replace with Settings page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openCreateFolderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CreateFolderPage(); // Use your page as a modal
      },
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false)
                .signOut(), // Uses Supabase auth
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              child: Icon(Icons.create_new_folder, color: Colors.white),
              onPressed: () => _openCreateFolderModal(context),
            )
          : null, // Only show FAB on Bookmark page
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

class BookmarkListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return FutureBuilder<List<Folder>>(
      future: bookmarkProvider.getFolders(), // Uses Supabase
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<Folder> folders = snapshot.data ?? [];
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            Folder folder = folders[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: folder.logoUrl != null && folder.logoUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(folder.logoUrl!),
                        radius: 30.0,
                      )
                    : CircleAvatar(
                        child: Text(
                            folder.name.isNotEmpty
                                ? folder.name[0]
                                : 'F', // Handle empty name
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        radius: 30.0,
                      ),
                title: Text(
                  folder.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${folder.bookmarkCount} bookmarks',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FolderPage(folder: folder),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
