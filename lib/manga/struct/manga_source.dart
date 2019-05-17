import 'package:dio/dio.dart';
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/manga/struct/manga_data.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_page.dart';
import 'package:Dokusho/models/persisted_model.dart';
import 'package:Dokusho/util/internet.dart';

abstract class MangaSource {
  String id;
  String name;
  String baseURL;
  String mangaPath;
  String apiURL;
  List<String> categories;

  MangaSource(String id, String name, String baseURL, String mangaSlug,
      String apiSlug, List<String> categories) {
    this.id = id;
    this.name = name;
    this.baseURL = baseURL;
    this.mangaPath = baseURL + mangaSlug;
    this.apiURL = baseURL + apiSlug;
    this.categories = categories;
  }

  Future<Response> read(String url, [bool proxy = false]) =>
      Internet.read(url, proxy);

  Future<String> readString(String url, [bool proxy = false]) =>
      Internet.readString(url, proxy);

  Future<MangaSource> readRequiredData();

  List<MangaEntry> topList(PersistedModel model, String exactCategory, int amount,
      [bool Function(MangaEntry entry) filter]);

  Future<MangaData> retrieveData(MangaEntry entry);

  Future<List<MangaPage>> retrieveImages(MangaChapter chapter);

  String linkTo(MangaEntry entry) {
    return this.mangaPath + entry.slug;
  }
}
