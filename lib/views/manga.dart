import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:Dokusho/models/global_scope.dart' as globals;
import 'package:Dokusho/manga/struct/manga_chapter.dart';
import 'package:Dokusho/manga/struct/manga_data.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';
import 'package:Dokusho/models/persisted_model.dart';
import 'package:Dokusho/views/home.dart';
import 'package:Dokusho/views/reader.dart';
import 'package:intl/intl.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:providerscope/providerscope.dart';
import 'package:url_launcher/url_launcher.dart';

class MangaView extends StatefulWidget {
  MangaView({Key key, this.source, this.entry, this.directedFromCategory})
      : super(key: key);

  final MangaSource source;
  final MangaEntry entry;
  final bool directedFromCategory;

  @override
  _MangaView createState() => _MangaView();
}

class _MangaView extends State<MangaView> {
  Widget containerElement;
  dynamic coverImage = AssetImage('assets/images/blank.png');
  MangaData mangaData;
  bool ascend = false;

  void _openChapter(MangaChapter ch, [bool pop = false]) {
    var model = Provide.value<PersistedModel>(context);
    model.setBookmark(widget.source, widget.entry, ch);
    setState(() {
      containerElement = _makePage();
    });
    if (pop) {
      Navigator.pop(context);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: true,
        builder: (context) => MangaReader(
              source: widget.source,
              entry: widget.entry,
              mangaData: mangaData,
              chapter: ch,
              opener: _openChapter,
            ),
      ),
    );
  }

  Widget _makeInfo(MangaData data) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Author:'),
                  Text('Artist:'),
                  Text('Last ch:'),
                  Text('Updated:'),
                  Text('Status:'),
                  Text('Source:')
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.author ?? 'Unknown',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    data.artist ?? 'Unknown',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    data.latestChapter()?.number.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    widget.entry.lastUpdated != null
                        ? DateFormat('yyyy-MM-dd').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                (widget.entry.lastUpdated * 1000).toInt()))
                        : 'Unknown',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    widget.entry.status.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    widget.source.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Wrap(
              spacing: 2.0,
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              children: widget.entry.categories
                  .map((c) => GestureDetector(
                        onTap: () {
                          if (widget.directedFromCategory) {
                            Navigator.pop(context);
                          }
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderNode(
                                    providers: globals.providers,
                                    child: HomeView(category: c),
                                  ),
                            ),
                          );
                        },
                        child: Chip(
                            labelPadding: EdgeInsets.all(2.0),
                            padding: EdgeInsets.all(2.0),
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            label: Text(
                              c,
                              style: TextStyle(
                                fontSize: 10.0,
                              ),
                            )),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _makeChapterList() {
    var model = Provide.value<PersistedModel>(context);
    var bookmark = model.findBookmark(widget.source, widget.entry);
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        var ch = mangaData.chapterAt(index, ascend);
        return GestureDetector(
          onTap: () => _openChapter(ch),
          child: Card(
            child: ListTile(
              title: Text(
                ch.titleText(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color:
                        bookmark != null && ch.compareTo(bookmark.lastRead) >= 0
                            ? Colors.grey[600] // read
                            : Colors.grey[300] // unread,
                    ),
              ),
              trailing: Icon(
                bookmark != null && ch.compareTo(bookmark.lastRead) >= 0
                    ? Icons.turned_in // read
                    : Icons.turned_in_not, // unread
              ),
            ),
          ),
        );
      }, childCount: mangaData.chapterCount()),
    );
  }

  Widget _makePage() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(5.0),
                        child: Image(fit: BoxFit.fill, image: coverImage),
                      ),
                    ),
                  ),
                  _makeInfo(mangaData),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text('Description:'),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  HtmlUnescape().convert(mangaData.description),
                  style: TextStyle(
                    color: Theme.of(context).accentColor.withOpacity(0.5),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                child: Text('Chapters:'),
              ),
            ]),
          ),
          _makeChapterList(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.source.retrieveData(widget.entry).then((data) {
        if (widget.entry.coverURL != null) {
          setState(() {
            coverImage = NetworkImage(widget.entry.coverURL);
          });
        }

        setState(() {
          mangaData = data;
          containerElement = _makePage();
        });
      });
    });
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

    return Provide<PersistedModel>(
        builder: (ctx, child, model) => Scaffold(
              appBar: AppBar(title: Text(widget.entry.name)),
              body: containerElement,
              floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
                children: <SpeedDialChild>[
                  SpeedDialChild(
                    child: Icon(
                      ascend ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      size: 30.0,
                    ),
                    backgroundColor: Colors.green,
                    label: 'Sort ' + (ascend ? 'descending' : 'ascending'),
                    labelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
                    onTap: () => setState(() {
                          ascend = !ascend;
                          containerElement = _makePage();
                        }),
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.launch),
                    backgroundColor: Colors.blue,
                    label: 'Open in browser',
                    labelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
                    onTap: () async {
                      var url = widget.source.linkTo(widget.entry);
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: model.isFavorite(widget.source, widget.entry)
                        ? Icon(Icons.delete)
                        : Icon(Icons.star),
                    backgroundColor:
                        model.isFavorite(widget.source, widget.entry)
                            ? Colors.red
                            : Colors.amber[300],
                    label: model.isFavorite(widget.source, widget.entry)
                        ? 'Remove from favorite'
                        : 'Add to favorites',
                    labelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
                    onTap: () {
                      if (model.isFavorite(widget.source, widget.entry)) {
                        model.removeFavorite(widget.source, widget.entry);
                      } else {
                        model.addFavorite(widget.source, widget.entry);
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.book),
                    backgroundColor: Colors.orange,
                    label: 'Read next chapter',
                    labelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
                    onTap: () {
                      var bookmark =
                          model.findBookmark(widget.source, widget.entry);
                      if (bookmark != null) {
                        var next = mangaData.nextChapter(bookmark.lastRead);
                        if (next != null) {
                          _openChapter(next);
                        } else {
                          // there is no other chapter
                          print('You are up-to-date!');
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                  title: Text('Up-to-date'),
                                  content:
                                      Text('You have read the latest release'),
                                ),
                          );
                        }
                      } else {
                        _openChapter(mangaData.firstChapter());
                      }
                    },
                  ),
                ],
              ),
            ));
  }
}
