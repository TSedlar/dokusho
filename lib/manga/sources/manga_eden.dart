import 'dart:math';

import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/manga/struct/manga_data.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_page.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';
import 'package:Dokusho/manga/struct/manga_status.dart';
import 'package:Dokusho/models/persisted_model.dart';

class MangaEden extends MangaSource {
  final String cdn = 'https://cdn.mangaeden.com/mangasimg/';
  final List<MangaEntry> list = List();

  String mangaPath;
  int lang;

  MangaEden(String id, String name, String mangaPath, [int lang = 0])
      : super(id, name, 'https://www.mangaeden.com/', mangaPath, 'api', [
          'Action',
          'Adult',
          'Adventure',
          'Comedy',
          'Doujinshi',
          'Drama',
          'Ecchi',
          'Fantasy',
          'Gender Bender',
          'Harem',
          'Historical',
          'Horror',
          'Mecha',
          'Mystery',
          'One Shot',
          'Psychological',
          'Romance',
          'School Life',
          'Sci-fi',
          'Seinen',
          'Shoujo',
          'Shounen',
          'Slice of Life',
          'Smut',
          'Sports',
          'Supernatural',
          'Tragedy',
          'Yaoi',
          'Yuri'
        ]) {
    this.lang = lang;
  }

  @override
  Future<MangaSource> readRequiredData() async {
    list.clear();
    var body = await read(apiURL + '/list/' + lang.toString() + '/');
    var json = body.data;
    var mangaArray = json['manga'];
    mangaArray.forEach((manga) {
      var entry = MangaEntry();

      entry.slug = manga['a'];
      entry.name = manga['t'];
      entry.id = manga['i'];
      entry.lastUpdated = manga['ld'];
      entry.popularity = manga['h'];

      entry.categories = List<String>();

      manga['c'].forEach((c) {
        entry.categories.add(c.toString());
      });

      if (manga['im'] != null) {
        entry.coverURL = cdn + manga['im'];
      }

      var status = manga['s'];

      if (identical(status, 0)) {
        entry.status = MangaStatus.UNKNOWN;
      } else {
        entry.status =
            identical(status, 1) ? MangaStatus.ONGOING : MangaStatus.COMPLETE;
      }

      list.add(entry);
    });
    return this;
  }

  @override
  List<MangaEntry> topList(PersistedModel model, String exactCategory, int n,
      [bool Function(MangaEntry entry) filter]) {
    var filtered = list;
    filtered = list
        .where((e) => exactCategory != null
            ? e.categories.contains(exactCategory)
            : model.hasAnyCategory(this, e.categories))
        .toList();
    filtered = filter != null ? filtered.where(filter).toList() : filtered;
    filtered.sort((a, b) {
      return b.popularity - a.popularity;
    });
    return filtered.sublist(0, min(filtered.length, n));
  }

  @override
  Future<MangaData> retrieveData(MangaEntry entry) async {
    var body = await read(apiURL + '/manga/' + entry.id + '/');
    var json = body.data;
    var data = MangaData();

    data.author = json['author'];
    data.artist = json['artist'];
    data.description = json['description'];
    data.imageURL = json['imageURL'];

    var chapters = List<MangaChapter>();

    json['chapters'].forEach((ch) {
      var chapter = MangaChapter();
      chapter.number = ch[0].toDouble();
      chapter.date = ch[1];
      chapter.title = ch[2];
      chapter.id = ch[3];
      chapters.add(chapter);
    });

    data.setChapters(chapters);

    return data;
  }

  @override
  Future<List<MangaPage>> retrieveImages(MangaChapter chapter) async {
    var body = await read(apiURL + '/chapter/' + chapter.id + '/');
    var json = body.data;
    var pages = List<MangaPage>();

    json['images'].forEach((img) {
      var page = MangaPage();
      page.index = img[0];
      page.imageURL = cdn + img[1];
      pages.add(page);
    });

    pages.sort((a, b) {
      return a.index - b.index;
    });

    return pages;
  }
}
