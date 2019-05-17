import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/manga/struct/manga_source.dart';
import 'package:Dokusho/models/persisted_model.dart';
import 'package:Dokusho/widgets/manga_card.dart';
import 'package:providerscope/providerscope.dart';

class FavoritesView extends StatefulWidget {
  FavoritesView({Key key}) : super(key: key);

  @override
  _FavoritesView createState() => _FavoritesView();
}

class _FavoritesView extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
  }

  Widget _makeFavoriteCard(MangaSource source, MangaEntry entry) {
    return ConstrainedBox(
      constraints: new BoxConstraints(minWidth: 160.0, maxWidth: 160.0),
      child: MangaCard(source: source, entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provide<PersistedModel>(
      builder: (ctx, child, model) => Scaffold(
            appBar: AppBar(title: Text('Favorites')),
            body: ListView(
              children: model.favorites.keys
                  .map((src) => Column(
                        children: [
                          ListTile(title: Text(src.name)),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.0),
                              child: ConstrainedBox(
                                constraints: new BoxConstraints(
                                  minHeight: 250.0,
                                  maxHeight: 250.0,
                                ),
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: model.favorites[src]
                                      .map((entry) => Padding(
                                            padding: EdgeInsets.only(
                                              right: 8.0,
                                              left: 8.0,
                                            ),
                                            child:
                                                _makeFavoriteCard(src, entry),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
    );
  }
}
