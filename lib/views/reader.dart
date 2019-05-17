import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/manga/struct/manga_data.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';
import 'package:Dokusho/util/shadows.dart';
import 'package:Dokusho/widgets/reader_end.dart';
import 'package:photo_view/photo_view.dart';

class MangaReader extends StatefulWidget {
  MangaReader(
      {Key key,
      this.source,
      this.entry,
      this.chapter,
      this.mangaData,
      this.opener})
      : super(key: key);

  final MangaSource source;
  final MangaEntry entry;
  final MangaData mangaData;
  final MangaChapter chapter;
  final Function(MangaChapter, [bool]) opener;

  @override
  _MangaReader createState() => _MangaReader();
}

class _MangaReader extends State<MangaReader> {
  Widget containerElement;
  int pageCount = -1;
  int progress = 1;
  bool hidden = true;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        var perPage = MediaQuery.of(context).size.width * (16 / 10);
        setState(() {
          progress = min(
            pageCount,
            max(0, (_scrollController.offset / perPage - 0.25)).round() + 1,
          );
        });
      });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.source.retrieveImages(widget.chapter).then((pages) {
        pages.sort((a, b) => a.index - b.index);
        setState(() {
          pageCount = pages.length;
          containerElement = GestureDetector(
            onTap: () {
              setState(() {
                hidden = !hidden;
              });
            },
            child: LayoutBuilder(
              builder: (ctx, constraints) => ListView.builder(
                  controller: _scrollController,
                  itemCount: pages.length + 1,
                  itemBuilder: (ctx, idx) {
                    return Container(
                        color: Colors.white,
                        width: constraints.maxWidth,
                        height: constraints.maxWidth * (16 / 10),
                        child: idx == pages.length
                            ? ReaderEnd(
                                source: widget.source,
                                entry: widget.entry,
                                mangaData: widget.mangaData,
                                chapter: widget.chapter,
                                opener: widget.opener,
                              )
                            : PhotoView(
                                imageProvider:
                                    NetworkImage(pages[idx].imageURL),
                                initialScale: PhotoViewComputedScale.contained,
                                backgroundDecoration:
                                    BoxDecoration(color: Colors.white),
                              ));
                  }),
            ),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    if (containerElement == null) {
      setState(() {
        containerElement = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: hidden
          ? null
          : AppBar(
              title: Text(
                  widget.entry.name + ' - ' + widget.chapter.number.toString()),
            ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          containerElement,
          Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: pageCount > 0
                ? Text('$progress/$pageCount',
                    style: TextStyle(
                      color: Colors.white,
                      shadows: Shadows.textOutline(1.0),
                    ))
                : null,
          ),
        ],
      ),
    );
  }
}
