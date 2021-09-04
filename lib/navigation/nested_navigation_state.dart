part of 'navigation.dart';

class _NestedNavigationState {
  _NestedNavigationState(this._pageFactory);

  final PageFactory _pageFactory;

  PageName? _activePage;
  PageName get activePage => _activePage!;

  final Map<PageName, Navigation> _pageNameNavigationMap =
      LinkedHashMap.from(<PageName, Navigation>{});

  Navigation get active => _pageNameNavigationMap[_activePage]!;
  List<Navigation> get all => _pageNameNavigationMap.values.toList();

  void addRootPage(
    PageName rootPage, {
    required Navigation parent,
    bool oneLevelNavigation = false,
  }) {
    _activePage ??= rootPage;

    _pageNameNavigationMap[rootPage] = Navigation(
      rootPage: rootPage,
      pageFactory: _pageFactory,
      parent: parent,
      oneLevelNavigation: oneLevelNavigation,
    );
  }

  void resetActivePage() {
    _activePage = _pageNameNavigationMap.keys.first;
  }

  Future<T?> navigateToNestedPage<T>(
    PageName pageName, {
    required Future<T?> Function(Navigation navigation) navigateCallback,
  }) {
    if (isRootPage(pageName)) {
      _activePage = pageName;
    }
    return navigateCallback(active);
  }

  bool isRootPage(PageName page) => _pageNameNavigationMap.keys.contains(page);
}
