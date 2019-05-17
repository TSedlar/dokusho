import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:Dokusho/models/global_scope.dart' as globals;
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';
import 'package:Dokusho/util/shadows.dart';
import 'package:Dokusho/views/manga.dart';
import 'package:providerscope/providerscope.dart';

class MangaCard extends StatefulWidget {
  MangaCard({Key key, this.source, this.entry, this.directedFromCategory}) : super(key: key);

  final MangaSource source;
  final MangaEntry entry;
  final bool directedFromCategory;

  @override
  _MangaCard createState() => _MangaCard();
}

class _MangaCard extends State<MangaCard> {
  dynamic coverImage = AssetImage('assets/images/blank.png');

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.entry.coverURL != null) {
        setState(() {
          coverImage = NetworkImage(widget.entry.coverURL);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderNode(
                  providers: globals.providers,
                  child: MangaView(
                    source: widget.source,
                    entry: widget.entry,
                    directedFromCategory: widget.directedFromCategory,
                  ),
                ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(5.0),
          child: Stack(
            children: [
              Image(
                fit: BoxFit.fill,
                image: coverImage,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1.2,
                height: MediaQuery.of(context).size.height * 1.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),
              new Padding(
                padding: EdgeInsets.all(5.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    widget.entry.name,
                    style: TextStyle(
                      inherit: true,
                      fontFamily: 'FiraSans',
                      fontSize: 16.0,
                      color: Colors.white,
                      shadows: Shadows.textOutline(1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
