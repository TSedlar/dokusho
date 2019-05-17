import 'package:dio/dio.dart';
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/manga/struct/manga_status.dart';
import 'package:Dokusho/util/internet.dart';

class MangaEntry {
  String slug;
  String name;
  String id;
  String coverURL;
  List<String> categories;
  MangaStatus status;
  double lastUpdated;
  int popularity;
  MangaChapter lastRead;

  Future<Response> readCover() async {
    return await Internet.read(coverURL, false);
  }

  Map<String, dynamic> toJsonable() {
    return {
      'slug': slug,
      'name': name,
      'id': id,
      'cover_url': coverURL,
      'categories': categories,
      'status': status.label,
      'last_updated': lastUpdated,
      'popularity': popularity,
      'last_read': lastRead != null ? lastRead.toJsonable() : null
    };
  }

  static MangaEntry fromJson(Map<String, dynamic> json) {
    var entry = MangaEntry();
    entry.slug = json['slug'];
    entry.name = json['name'];
    entry.id = json['id'];
    entry.coverURL = json['cover_url'];
    entry.categories =
        (json['categories'] as List<dynamic>).map((i) => i.toString()).toList();
    entry.status = MangaStatus.fromString(json['status']);
    entry.lastUpdated = json['last_updated'];
    entry.popularity = json['popularity'];
    entry.lastRead = json['last_read'] != null
        ? MangaChapter.fromJson(json['last_read'])
        : null;
    return entry;
  }
}
