import 'package:Dokusho/models/global_scope.dart' as globals;
import 'package:providerscope/providerscope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Dokusho/views/home.dart';

void main() => runApp(MainApplication());

class MainApplication extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dokusho',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.white,
          brightness: Brightness.dark),
      home: ProviderNode(
        providers: globals.providers,
        child: HomeView(),
      ),
    );
  }
}
