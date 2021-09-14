import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigator_20/shared/logger.dart';
import 'package:uni_links/uni_links.dart';

import 'navigation/index.dart';
import 'shared/deep_link_parser.dart';

class App extends StatefulWidget {
  const App(this.navigation);

  final Navigation navigation;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late StreamSubscription _deepLinkSubscription;
  @override
  void initState() {
    super.initState();
    _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        final pages = DeepLinkParser.parse(uri);
        for (final page in pages) {
          widget.navigation.navigate(
            page,
            
          );
        }
      }
    }, onError: (Object err) {
      Log.instance.e('Failed to handle deeplink', err);
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription.cancel();
    super.dispose();
  }

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
      home: SingleNavigationHostView(navigation: widget.navigation),
    );
  }
}
