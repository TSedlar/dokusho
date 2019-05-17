import 'package:flutter/material.dart';
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/manga/struct/manga_data.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';

class ReaderEnd extends StatefulWidget {
  ReaderEnd({Key key, this.source, this.entry, this.mangaData, this.chapter, this.opener})
      : super(key: key);

  final MangaSource source;
  final MangaEntry entry;
  final MangaData mangaData;
  final MangaChapter chapter;
  final Function(MangaChapter, [bool]) opener;

  @override
  _ReaderEnd createState() => _ReaderEnd();
}

class _ReaderEnd extends State<ReaderEnd> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var next = widget.mangaData.nextChapter(widget.chapter);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            'End of chapter ' + widget.chapter.number.toString(),
            style: TextStyle(color: theme.primaryColor),
          ),
          next != null
              ? RaisedButton(
                  color: theme.primaryColor,
                  child: Text('Go to chapter ' + next.number.toString()),
                  onPressed: () => widget.opener(next, true),
                )
              : Text(
                  'This is the latest chapter!',
                  style: TextStyle(color: theme.primaryColor),
                ),
        ],
      ),
    );
  }
}
