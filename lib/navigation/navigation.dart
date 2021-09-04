import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'index.dart';

part 'navigation.extensions.dart';
part 'nested_navigation_state.dart';

const String navigationLogName = 'Navigation';

class Navigation extends ChangeNotifier {
  Navigation({
    required this.rootPage,
    required PageFactory pageFactory,
    Navigation? parent,
    bool oneLevelNavigation = false,
  })  : _pageFactory = pageFactory,
        _navInfoList = [
          NavigationInfo(
            rootPage,
            pageFactory.create(
              PlainPageConfiguration(pageName: rootPage),
            ),
            null,
          ),
        ],
        _navigatorKey = GlobalKey<NavigatorState>(),
        _parent = parent,
        _oneLevelNavigation = oneLevelNavigation;

  static Navigation of(BuildContext context) => context.read<Navigation>();

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// There can be multiple instance of [Navigation] (for root and nested navigation flows),
  ///  so subscribers of this stream will receive updates when any of the [Navigation] instances
  ///  changes its state.
  Stream<NavigationUpdateInfo> get anyInstanceUpdatesStream =>
      _anyInstanceNavUpdateController.stream;

  /// If set to `true` we disable nested navigation. New page will open over current one 
  /// instead of inside it
  bool get oneLevelNavigation => _oneLevelNavigation;

  final PageName rootPage;

  /// Stack of pages to be shown in [Navigator].
  List<MaterialPage> get pages => List.unmodifiable(
      _navInfoList.map<MaterialPage>((navInfo) => navInfo.page));

  PageName get currentPage => _targetPageNavInfo.pageName;

  Navigation? getActiveNestedNavigation(Page page) =>
      _pageNestedNavigationsMap[page]?.active;

  List<Navigation>? getAllNestedNavigations(Page page) =>
      _pageNestedNavigationsMap[page]?.all;

  static final _anyInstanceNavUpdateController =
      StreamController<NavigationUpdateInfo>.broadcast();

  final PageFactory _pageFactory;
  final List<NavigationInfo> _navInfoList;
  final Navigation? _parent;
  final bool _oneLevelNavigation;
  final GlobalKey<NavigatorState> _navigatorKey;

  /// We need this to be able to store the root navigation tree when something
  /// was pushed to global navigation. Each page pushed as global we associate
  /// [_NestedNavigationState] which contains information about nested
  /// navigation.
  final Map<Page, _NestedNavigationState> _pageNestedNavigationsMap = {};

  Page get _activePage => _navInfoList.last.page;
  _NestedNavigationState? get _activeNestedState =>
      _pageNestedNavigationsMap[_activePage];

  Navigation? get _activeNestedNavigation => _activeNestedState?.active;

  Navigation get _rootNavigation {
    var rootNavigation = this;
    while (rootNavigation._parent != null) {
      rootNavigation = rootNavigation._parent!;
    }
    return rootNavigation;
  }

  List<NavigationInfo> get _navigationStack {
    return [
      ..._navInfoList.map((navInfo) {
        return [
          navInfo,
          ...?_pageNestedNavigationsMap[navInfo.page]?.active._navigationStack,
        ];
      }).expand((page) => page)
    ];
  }

  NavigationInfo get _targetPageNavInfo =>
      _activeNestedNavigation?._targetPageNavInfo ?? _navInfoList.last;


  /// Uses to register nested navigation via [MultiNavigationHostView]
  void registerNestedNavigation(
    PageName rootPage, {
    bool oneLevelNavigation = false,
  }) {
    if (!_pageNestedNavigationsMap.containsKey(_activePage)) {
      _pageNestedNavigationsMap[_activePage] =
          _NestedNavigationState(_pageFactory);
    }

    _activeNestedState!.addRootPage(
      rootPage,
      parent: this,
      oneLevelNavigation: oneLevelNavigation,
    );

    if ((_parent == null ||
            _parent?._activeNestedNavigation?.rootPage == this.rootPage) &&
        _activeNestedState?.all.length == 1) {
      _notifyNavigationUpdated(_targetPageNavInfo, isNotifyListeners: false);
    }
  }

  void pop({
    Object? result,
    bool notifyNavUpdatesStreamListeners = true,
  }) =>
      _rootNavigation._pop(
        result: result,
        notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
      );

  void _pop({
    Object? result,
    bool notifyNavUpdatesStreamListeners = true,
  }) {
    if (_activeNestedNavigation != null &&
        _activeNestedNavigation!.pages.length > 1) {
      _activeNestedNavigation!._pop(result: result);
    } else {
      NavigationInfo? targetPageNavInfo;
      if (_navInfoList.length > 1) {
        _removeLastPage(result: result);
        targetPageNavInfo = _targetPageNavInfo;
      } else {
        SystemNavigator.pop();
      }

      _notifyNavigationUpdated(
        targetPageNavInfo,
        isBackward: true,
        notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
      );
    }
  }

  Future<T?> navigateForResult<T>(
    PageConfiguration pageConfig, {
    bool globalNavigation = false,
    bool replace = false,
    bool resetNestedNavState = false,
    bool notifyNavUpdatesStreamListeners = true,
  }) async {
    final navigateGlobally = globalNavigation ||
        pageConfig is ModalPageConfiguration ||
        (pageConfig is PlainPageConfiguration && pageConfig.isFullScreenDialog);

    final navigateGloballyFromNestedNavigation =
        navigateGlobally && _parent != null;
    if (navigateGloballyFromNestedNavigation) {
      return _parent!.navigateForResult<T>(
        pageConfig,
        globalNavigation: navigateGlobally,
        replace: replace,
        resetNestedNavState: resetNestedNavState,
        notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
      );
    }

    if (_avoidNestedNavigation(
        navigateGlobally, pageConfig, _activeNestedState)) {
      return _processInternalPage<T>(
        pageConfig,
        replace,
        resetNestedNavState,
        notifyNavUpdatesStreamListeners,
      );
    } else {
      return _processNestedPage<T>(
        _activeNestedState!,
        pageConfig,
        replace,
        resetNestedNavState,
        notifyNavUpdatesStreamListeners,
      );
    }
  }

  bool _avoidNestedNavigation(
    bool navigateGlobally,
    PageConfiguration pageConfig,
    _NestedNavigationState? navigationState,
  ) {
    return navigateGlobally ||
        pageConfig.pageName == rootPage ||
        navigationState == null ||
        _isOneLevelNestedNavigation(navigationState, page: pageConfig.pageName);
  }

  bool _isOneLevelNestedNavigation(
    _NestedNavigationState? navigationState, {
    required PageName page,
  }) =>
      navigationState != null &&
      !navigationState.isRootPage(page) &&
      navigationState.active.oneLevelNavigation;

  Future<T?> _processInternalPage<T>(
    PageConfiguration pageConfig,
    bool replace,
    bool resetNestedNavState,
    bool notifyNavUpdatesStreamListeners,
  ) {
    final newPage = _pageFactory.create(pageConfig);

    if (!replace && !resetNestedNavState && _currentPagesContains(newPage)) {
      return Future.value(null);
    }

    if (replace || resetNestedNavState) {
      final samePageIndex = _navInfoList
          .indexWhere((pageInfo) => pageInfo.page.name == newPage.name);

      while (_navInfoList.length - 1 > samePageIndex && samePageIndex >= 0) {
        _removeLastPage();
      }

      if (samePageIndex != 0 || replace) {
        _removeLastPage();
      } else {
        return _updateRootPage<T?>(
            samePageIndex, notifyNavUpdatesStreamListeners);
      }
    }

    return _addInternalPage<T>(
        pageConfig, newPage, notifyNavUpdatesStreamListeners);
  }

  Future<T?> _processNestedPage<T>(
    _NestedNavigationState navigationState,
    PageConfiguration pageConfig,
    bool replace,
    bool resetNestedNavState,
    bool notifyNavUpdatesStreamListeners,
  ) {
    final activePage = navigationState.activePage;
    final navigateForResult = navigationState.navigateToNestedPage(
      pageConfig.pageName,
      navigateCallback: (nestedNavigation) {
        return nestedNavigation.navigateForResult<T>(
          pageConfig,
          replace: replace,
          resetNestedNavState: resetNestedNavState,
          notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
        );
      },
    );

    if (activePage != navigationState.activePage) {
      _notifyNavigationUpdated(
        _targetPageNavInfo,
        notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
      );
    }

    return navigateForResult;
  }

  bool _currentPagesContains(Page<dynamic> newPage) =>
      _navInfoList.any((pageInfo) => pageInfo.page.name == newPage.name);

  Future<T> _addInternalPage<T>(
    PageConfiguration pageConfig,
    MaterialPage<dynamic> newPage,
    bool notifyNavUpdatesStreamListeners,
  ) {
    final resultCompleter = Completer<T>();
    _navInfoList
        .add(NavigationInfo(pageConfig.pageName, newPage, resultCompleter));

    _notifyNavigationUpdated(
      _targetPageNavInfo,
      notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
    );

    return resultCompleter.future;
  }

  void _removeLastPage({Object? result}) {
    final pageInfo = _navInfoList.removeLast();
    _pageNestedNavigationsMap.remove(pageInfo.page);
    pageInfo.resultCompleter?.complete(result);
  }

  void _notifyNavigationUpdated(
    NavigationInfo? targetPageInfo, {
    bool isBackward = false,
    bool isNotifyListeners = true,
    bool notifyNavUpdatesStreamListeners = true,
  }) {
    if (isNotifyListeners) {
      notifyListeners();
    }

    if (targetPageInfo != null && notifyNavUpdatesStreamListeners) {
      _anyInstanceNavUpdateController.sink.add(
        NavigationUpdateInfo(
          targetPageName: targetPageInfo.pageName,
          targetScreenName: targetPageInfo.page.name ?? '',
          isBackNavigation: isBackward,
        ),
      );
    }
  }

  Future<T?> _updateRootPage<T>(
      int samePageIndex, bool notifyNavUpdatesStreamListeners) {
    final navInfo = _navInfoList[samePageIndex];
    _pageNestedNavigationsMap[navInfo.page]?.resetActivePage();
    _notifyNavigationUpdated(
      _targetPageNavInfo,
      notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
    );
    return navInfo.resultCompleter?.future as Future<T?>;
  }
}


class NavigationInfo {
  const NavigationInfo(
    this.pageName,
    this.page,
    this.resultCompleter,
  );

  final PageName pageName;
  final MaterialPage page;
  final Completer<Object?>? resultCompleter;
}

class NavigationUpdateInfo {
  NavigationUpdateInfo({
    required this.targetPageName,
    required this.targetScreenName,
    this.isBackNavigation = false,
  });

  final PageName targetPageName;
  final String targetScreenName;
  final bool isBackNavigation;
}
