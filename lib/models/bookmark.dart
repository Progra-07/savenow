class Bookmark {
  final String id;
  final String title;
  final String url;
  final String folderId;

  Bookmark({
    required this.id,
    required this.title,
    required this.url,
    required this.folderId,
  });

  // Parse from Supabase's row (Map<String, dynamic>)
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      folderId: json['folder_id'],
    );
  }

  // Convert to JSON for Supabase insertion
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'folder_id': folderId,
    };
  }
}
