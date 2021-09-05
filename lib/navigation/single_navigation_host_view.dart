import 'package:flutter/material.dart';
import 'package:navigator_20/shared/logger.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class SingleNavigationHostView extends StatefulWidget {
  const SingleNavigationHostView({
    required this.navigation,
  });

  final Navigation navigation;

  @override
  _SingleNavigationHostViewState createState() => _SingleNavigationHostViewState();
}

class _SingleNavigationHostViewState extends State<SingleNavigationHostView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    widget.navigation.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Navigation>.value(
      value: widget.navigation,
      child: Consumer<Navigation>(
        builder: (context, navigation, child) {
          Log.instance.d(
            'Single Nav (${navigation.navigatorKey}) is being rebuilt',
          );

          return Navigator(
            key: navigation.navigatorKey,
            onPopPage: _onPopPage,
            pages: navigation.pages,
            restorationScopeId: navigation.navigatorKey.toString(),
          );
        },
      ),
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) return false;

    widget.navigation.pop(result: result);

    return true;
  }
}
