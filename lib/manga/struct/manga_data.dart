import 'package:dio/dio.dart';
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/util/internet.dart';

class MangaData {
  String author;
  String artist;
  String description;
  String imageURL;
  List<MangaChapter> _chapters;

  Future<Response> readCover() async {
    return await Internet.read(imageURL, false);
  }

  void setChapters(List<MangaChapter> chapters) {
    chapters.sort((a, b) => b.number.compareTo(a.number)); // default descending
    _chapters = chapters;
  }

  MangaChapter latestChapter() {
    return _chapters.first;
  }

  MangaChapter firstChapter() {
    return _chapters.last;
  }

  MangaChapter nextChapter(MangaChapter ch) {
    if (ch == null) {
      return null;
    }
    var idx = _chapters.indexWhere((c) => c.titleText() == ch.titleText());
    if (idx >= 0) {
      // remember, it's in descending order
      return idx - 1 >= 0 ? _chapters[idx - 1] : null;
    } else {
      return null;
    }
  }

  MangaChapter chapterAt(int index, [bool ascend = false]) {
    return ascend ? _chapters[_chapters.length - index - 1] : _chapters[index];
  }

  int chapterCount() {
    return _chapters.length;
  }
}
