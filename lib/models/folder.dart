import 'package:intl/intl.dart';

class Folder {
  final String id;
  final String name;
  final String details;
  final String? logoUrl;
  final int bookmarkCount;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.details,
    this.logoUrl,
    required this.bookmarkCount,
    required this.createdAt,
  });

  // Parse from Supabase's row (Map<String, dynamic>)
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      details: json['details'] ?? '',
      logoUrl: json['logo_url'],
      bookmarkCount: json['bookmark_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert to JSON for Supabase insertion
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details,
      'logo_url': logoUrl,
      'bookmark_count': bookmarkCount,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
    };
  }
}
