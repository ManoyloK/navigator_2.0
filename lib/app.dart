import 'package:flutter/material.dart';

import 'navigation/index.dart';

class App extends StatelessWidget {
  const App(this. navigation);

final Navigation navigation;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Router Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      restorationScopeId: 'app',
      home: SingleNavigationHostView(navigation: navigation),
    );
  }
}
