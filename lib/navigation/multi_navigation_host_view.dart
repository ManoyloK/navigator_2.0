import 'package:flutter/material.dart';
import 'package:navigator_20/shared/logger.dart';
import 'package:provider/provider.dart';

import 'index.dart';
import 'navigation.dart';

typedef ViewBuilder = Widget Function(
    BuildContext context, List<Widget> children);
typedef ActiveViewIndexChanged = void Function(int index);

class MultiNavigationHostView extends StatefulWidget {
  const MultiNavigationHostView({
    Key? key,
    required this.navigation,
    required this.activeViewIndexChanged,
    required this.viewBuilder,
    required this.oneLevelNavigation,
    this.roots = const <PageName>[],
  }) : super(key: key);

  final Navigation navigation;
  final ActiveViewIndexChanged activeViewIndexChanged;
  final ViewBuilder viewBuilder;
  final bool oneLevelNavigation;
  final List<PageName> roots;

  @override
  _MultiNavigationHostViewState createState() =>
      _MultiNavigationHostViewState();
}

class _MultiNavigationHostViewState extends State<MultiNavigationHostView> {
  /// Needed to point to the right [Navigation] when new page is pushed as global
  /// navigation and root [Navigation] is updated.
  late Page _nestedNavigationsHostPage;
  Navigation? _activeNestedNavigation;
  late VoidCallback _onNavigationUpdated;

  @override
  void initState() {
    super.initState();
    _initNavigationUpdatedListener();

    _nestedNavigationsHostPage = widget.navigation.pages.last;
    for (final rootPageName in widget.roots) {
      widget.navigation.registerNestedNavigation(
        rootPageName,
        oneLevelNavigation: widget.oneLevelNavigation,
      );
    }
    _activeNestedNavigation =
        widget.navigation.getActiveNestedNavigation(_nestedNavigationsHostPage);
    widget.navigation.addListener(_onNavigationUpdated);
  }

  @override
  void dispose() {
    widget.navigation.removeListener(_onNavigationUpdated);
    super.dispose();
  }

  void _initNavigationUpdatedListener() {
    _onNavigationUpdated = () {
      Log.instance.d(
        'Multi Nav (${widget.navigation.navigatorKey}) is being updated',
      );

      if (_updateActiveNestedNavigation()) {
        setState(() {});
      }
    };
  }

  bool _updateActiveNestedNavigation() {
    final newNestedNavigation =
        widget.navigation.getActiveNestedNavigation(_nestedNavigationsHostPage);
    if (_activeNestedNavigation != newNestedNavigation) {
      final isRootPageUpdated = _activeNestedNavigation != null;
      _activeNestedNavigation = newNestedNavigation;

      if (isRootPageUpdated) _updateActiveViewIndex();
      return true;
    }
    return false;
  }

  void _updateActiveViewIndex() {
    final currentRootPageIndex =
        widget.roots.indexOf(_activeNestedNavigation!.rootPage);
    widget.activeViewIndexChanged.call(currentRootPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return widget.viewBuilder(
      context,
      widget.navigation
          .getAllNestedNavigations(_nestedNavigationsHostPage)!
          .map(
            (nestedNavigation) => nestedNavigation.oneLevelNavigation
                ? nestedNavigation.pages.single.child
                : _OffstageNavigator(
                    navigation: nestedNavigation,
                    hide: _activeNestedNavigation != nestedNavigation,
                  ),
          )
          .toList(),
    );
  }
}

class _OffstageNavigator extends StatelessWidget {
  const _OffstageNavigator({
    Key? key,
    required this.navigation,
    required this.hide,
  }) : super(key: key);

  final Navigation navigation;
  final bool hide;

  @override
  Widget build(BuildContext context) {
    final navigator = ChangeNotifierProvider<Navigation>.value(
      value: navigation,
      child: Consumer<Navigation>(
        builder: (context, navigation, child) {
          Log.instance.d(
            'Offstage Nav (${navigation.navigatorKey}) is being rebuilt',
          );
          return Navigator(
            key: navigation.navigatorKey,
            pages: navigation.pages,
            onPopPage: _onPopPage,
            restorationScopeId: navigation.navigatorKey.toString(),
          );
        },
      ),
    );

    return Offstage(
      key: ValueKey(navigation.rootPage),
      offstage: hide,
      child: navigator,
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    navigation.pop(result: result);
    return route.didPop(result);
  }
}
