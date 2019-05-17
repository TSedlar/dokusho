import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Dokusho/models/global_scope.dart' as globals;
import 'package:Dokusho/views/favorites.dart';
import 'package:Dokusho/views/home.dart';
import 'package:providerscope/providerscope.dart';

class Sidebar extends StatefulWidget {
  Sidebar({Key key}) : super(key: key);

  @override
  _Sidebar createState() => _Sidebar();
}

class _Sidebar extends State<Sidebar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 120.0,
          child: DrawerHeader(
            child: Text('Dokusho App', style: TextStyle(fontSize: 18.0)),
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderNode(
                        providers: globals.providers,
                        child: HomeView(),
                      ),
                ),
              ),
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text('Favorites'),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderNode(
                        providers: globals.providers,
                        child: FavoritesView(),
                      ),
                ),
              ),
        ),
      ],
    );
  }
}
