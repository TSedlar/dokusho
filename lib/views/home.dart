import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:Dokusho/manga/struct/manga_entry.dart';
import 'package:Dokusho/models/persisted_model.dart';
import 'package:Dokusho/widgets/manga_card.dart';
import 'package:Dokusho/widgets/sidebar.dart';
import 'package:providerscope/providerscope.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key, this.category}) : super(key: key);

  final String category;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String source;
  Widget containerElement;
  bool searching = false;
  bool submitted = false;

  Widget _makeLoader(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
          )
        ],
      ),
    );
  }

  void _setSourceGrid([bool Function(MangaEntry entry) filter]) {
    var theme = Theme.of(context);
    setState(() {
      containerElement = _makeLoader(theme);
    });
    var model = Provide.value<PersistedModel>(context);
    model.sources[source].readRequiredData().then((src) {
      var size = MediaQuery.of(context).size;
      double itemWidth = (size.width / 2);
      double itemHeight = (itemWidth) * (16 / 10);
      var topList = src.topList(model, widget.category, 100, filter);
      setState(
        () {
          containerElement = GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              childAspectRatio: (itemWidth / itemHeight),
            ),
            itemCount: topList.length,
            itemBuilder: (ctx, idx) => MangaCard(
                source: src,
                entry: topList[idx],
                directedFromCategory: widget.category != null),
          );
        },
      );
    });
  }

  void _makeCategoryDialog() {
    var model = Provide.value<PersistedModel>(context);
    var filters = model.categoryFilters[model.sources[source]];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text('Categories'),
            content: SingleChildScrollView(
              child: Column(
                children: filters.entries
                    .map(
                      (i) => StatefulBuilder(
                          builder: (ctx, setState) => CheckboxListTile(
                              title: Text(i.key),
                              value: filters[i.key],
                              onChanged: (val) {
                                setState(() {
                                  model.setCategoryFilter(
                                    model.sources[source],
                                    i.key,
                                    val,
                                  );
                                });
                              })),
                    )
                    .toList(),
              ),
            ),
          ),
    ).then((_) {
      _setSourceGrid();
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var model = Provide.value<PersistedModel>(context);
      source = model.sources.entries.first.key;
      model.readFavorites();
      model.readBookmarks();
      model.readFilters();
      _setSourceGrid();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    if (containerElement == null) {
      setState(() {
        containerElement = _makeLoader(theme);
      });
    }

    return Provide<PersistedModel>(
      builder: (ctx, child, model) => Scaffold(
            drawer: widget.category != null ? null : Drawer(child: Sidebar()),
            appBar: AppBar(
              title: Theme(
                data: theme.copyWith(
                    canvasColor: theme.primaryColor,
                    brightness: theme.brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
                child: widget.category != null
                    ? Text(widget.category)
                    : (searching
                        ? PreferredSize(
                            preferredSize: const Size.fromHeight(48.0),
                            child: TextField(
                              autofocus: true,
                              decoration:
                                  InputDecoration(hintText: 'Search...'),
                              onSubmitted: (String text) {
                                submitted = true;
                                _setSourceGrid((entry) => entry.name
                                    .toLowerCase()
                                    .contains(text.toLowerCase()));
                              },
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              value: source,
                              items: Provide.value<PersistedModel>(context)
                                  .sources
                                  .entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(
                                            entry.value.name,
                                            style: TextStyle(
                                              color: theme.accentColor,
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (newSource) {
                                setState(
                                  () {
                                    source = newSource;
                                    _setSourceGrid();
                                  },
                                );
                              },
                            ),
                          )),
              ),
              actions: widget.category != null
                  ? []
                  : [
                      IconButton(
                        icon: Icon(Icons.filter_list),
                        onPressed: () => _makeCategoryDialog(),
                      ),
                      IconButton(
                        icon: Icon(searching ? Icons.close : Icons.search),
                        onPressed: () {
                          setState(() {
                            searching = !searching;
                            if (!searching && submitted) {
                              _setSourceGrid();
                            }
                            submitted = false;
                          });
                        },
                      )
                    ],
            ),
            body: containerElement,
          ),
    );
  }
}
