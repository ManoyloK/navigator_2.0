import 'package:flutter/material.dart';
import 'package:navigator_20/shared/logger.dart';
import 'package:provider/provider.dart';

import 'index.dart';
import 'navigation.dart';

typedef ViewBuilder = Widget Function(
    BuildContext context, List<Widget> children);
typedef ActiveRootViewChanged = void Function(int activeRootIndex);

class MultiNavigationHostView extends StatefulWidget {
  const MultiNavigationHostView({
    Key? key,
    required this.navigation,
    required this.activeRootViewChanged,
    required this.viewBuilder,
    required this.oneLevelNavigation,
    this.roots = const <PageName>[],
  }) : super(key: key);

  final Navigation navigation;
  final ActiveRootViewChanged activeRootViewChanged;
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

  @override
  void initState() {
    super.initState();

    _nestedNavigationsHostPage = widget.navigation.pages.last;
    for (final rootPageName in widget.roots) {
      widget.navigation.registerNestedNavigation(
        rootPageName,
        oneLevelNavigation: widget.oneLevelNavigation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Navigation>(
      builder: (context, navigation, child) {
        Log.instance.d(
          'Multi Nav (${navigation.navigatorKey}) is being rebuilt',
        );

        final activeNestedNavigation =
            navigation.getActiveNestedNavigation(_nestedNavigationsHostPage);
        if (_activeNestedNavigation != activeNestedNavigation) {
          final isRootPageUpdated = _activeNestedNavigation!=null;
          _activeNestedNavigation = activeNestedNavigation;
          if(isRootPageUpdated){
          final currentRootPageIndex =
              widget.roots.indexOf(_activeNestedNavigation!.rootPage);
          widget.activeRootViewChanged.call(currentRootPageIndex);
          }
        }

        return widget.viewBuilder(
          context,
          navigation.getAllNestedNavigations(_nestedNavigationsHostPage)!.map(
            (nestedNavigation) {
              return nestedNavigation.oneLevelNavigation
                  ? nestedNavigation.pages.single.child
                  : _OffstageNavigator(
                      navigation: nestedNavigation,
                      hide: activeNestedNavigation != nestedNavigation,
                    );
            },
          ).toList(),
        );
      },
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
