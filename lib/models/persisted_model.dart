import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:providerscope/providerscope.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Dokusho/manga/sources/manga_eden_en.dart';
import 'package:Dokusho/manga/sources/manga_eden_it.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';

final _encoder = JsonEncoder();
final _decoder = JsonDecoder();

class PersistedModel extends Model {
  final Map<String, MangaSource> sources = Map.fromIterable(
    [
      MangaEdenEN(),
      MangaEdenIT(),
    ],
    key: (item) => (item as MangaSource).id,
    value: (item) => (item as MangaSource),
  );

  final Map<MangaSource, List<MangaEntry>> favorites = {};
  final Map<MangaSource, List<MangaEntry>> bookmarks = {};
  final Map<MangaSource, Map<String, bool>> categoryFilters = {};

  bool isFavorite(MangaSource source, MangaEntry entry) {
    return favorites.containsKey(source) &&
        favorites[source].any((e) => e.id == entry.id);
  }

  void addFavorite(MangaSource source, MangaEntry entry) async {
    favorites.putIfAbsent(source, () => []);
    if (!isFavorite(source, entry)) {
      favorites[source].add(entry);
      notifyListeners();
      writeFavorites();
    }
  }

  void removeFavorite(MangaSource source, MangaEntry entry) async {
    if (favorites.containsKey(source)) {
      if (!favorites[source].remove(entry) && entry.id != null) {
        favorites[source].removeWhere((e) => e.id == entry.id);
      }
      if (favorites[source].isEmpty) {
        favorites.remove(source);
      }
      notifyListeners();
      writeFavorites();
    }
  }

  MangaEntry findBookmark(MangaSource source, MangaEntry entry) {
    if (bookmarks.containsKey(source)) {
      var idx = bookmarks[source].indexWhere((e) => e.id == entry.id);
      if (idx >= 0) {
        return bookmarks[source][idx];
      }
    }
    return null;
  }

  void setBookmark(MangaSource source, MangaEntry entry, MangaChapter ch) {
    bookmarks.putIfAbsent(source, () => []);
    var currentBookmark = findBookmark(source, entry);
    if (currentBookmark != null) {
      currentBookmark.lastRead = ch;
    } else {
      entry.lastRead = ch;
      bookmarks[source].add(entry);
    }
    notifyListeners();
    writeBookmarks();
  }

  bool hasAnyCategory(MangaSource source, List<String> categories) {
    if (categoryFilters.containsKey(source)) {
      var filters = categoryFilters[source];
      var categoried = filters.keys.where((i) => filters[i]);
      return categories.any((c) => categoried.contains(c));
    }
    return false;
  }

  void _writeMap(Map<MangaSource, List<MangaEntry>> map, String file) async {
    Map<String, dynamic> json = {};
    map.forEach((source, entries) {
      var jsonEntries = [];
      entries.forEach((entry) => jsonEntries.add(entry.toJsonable()));
      json[source.id] = {'entries': jsonEntries};
    });

    var appDir = await getApplicationDocumentsDirectory();
    var jsonDest = File(appDir.path + file);

    return jsonDest.writeAsStringSync(_encoder.convert(json));
  }

  void _readToMap(
      Map<MangaSource, List<MangaEntry>> target, String file) async {
    var appDir = await getApplicationDocumentsDirectory();
    var jsonDest = File(appDir.path + file);

    var jsonExists = await jsonDest.exists();

    if (jsonExists) {
      var jsonData = await jsonDest.readAsStringSync();

      var json = _decoder.convert(jsonData);

      Map<MangaSource, List<MangaEntry>> newMap = {};

      json.forEach((key, data) {
        var entryList = <MangaEntry>[];
        data.entries.first.value.forEach((entry) {
          entryList.add(MangaEntry.fromJson(entry));
        });
        newMap[sources[key]] = entryList;
      });

      target.clear();
      newMap.forEach((k, v) => target.putIfAbsent(k, () => v));
    }
  }

  void writeFavorites() async => _writeMap(favorites, '/favorites.json');

  void readFavorites() async => _readToMap(favorites, '/favorites.json');

  void writeBookmarks() async => _writeMap(bookmarks, '/bookmarks.json');

  void readBookmarks() async => _readToMap(bookmarks, '/bookmarks.json');

  void setCategoryFilter(MangaSource source, String key, bool val) {
    categoryFilters.putIfAbsent(source, () => {});
    categoryFilters[source][key] = val;
    notifyListeners();
    writeFilters();
  }

  void writeFilters() async {
    Map<String, dynamic> json = {};

    categoryFilters.forEach((src, filters) {
      var srcObj = {};
      filters.forEach((category, value) {
        srcObj[category] = value;
      });
      json[src.id] = srcObj;
    });

    var appDir = await getApplicationDocumentsDirectory();
    var jsonDest = File(appDir.path + '/filters.json');

    return jsonDest.writeAsStringSync(_encoder.convert(json));
  }

  void readFilters() async {
    // set all filters enabled by default
    sources.values.forEach((source) {
      categoryFilters.putIfAbsent(source, () => {});
      source.categories.forEach((c) => categoryFilters[source][c] = true);
    });
    // read in filters from file and set
    var appDir = await getApplicationDocumentsDirectory();
    var jsonDest = File(appDir.path + '/filters.json');

    var jsonExists = await jsonDest.exists();

    if (jsonExists) {
      var jsonData = await jsonDest.readAsStringSync();

      var json = _decoder.convert(jsonData);

      json.forEach((src, filters) {
        filters.forEach((filter, value) {
          categoryFilters[sources[src]][filter] = value;
        });
      });
    }
  }
}
