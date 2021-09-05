part of 'navigation.dart';

extension NavigationExt on Navigation {
  String get currentPagePath => _navigationStack
      .map((e) => e.page.name! + (e.page.arguments != null ? '/${e.page.arguments}' : ''))
      .join('');

  /// In most of the cases we do not depend on any result from the page we navigate to. If we make it
  /// return [Future] and await on it, then we will stop the current page's bloc from being able to
  /// handle other events.
  void navigate(
    PageConfiguration pageConfig, {
    bool globalNavigation = false,
    bool update = false,
    bool replace = false,
    bool resetNestedNavState = false,
    bool notifyNavUpdatesStreamListeners = true,
  }) {
    navigateForResult<dynamic>(
      pageConfig,
      globalNavigation: globalNavigation,
      replace: replace,
      resetNestedNavState: resetNestedNavState,
      notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners,
    );
  }

  /// Allows to do multiple navigation actions without calling redundant rebuid methods
  void navigateMultiplePages(
    List<NavigationConfig> navConfigs, {
    bool resetNestedNavStateOnLastPage = false,
  }) {
    for (final navConfig in navConfigs) {
      final isLastNavConfig = navConfig == navConfigs.last;

      switch (navConfig.action) {
        case NavigationAction.push:
          navigate(
            PlainPageConfiguration(
              pageName: navConfig.pageName!,
            ),
            globalNavigation: navConfig.globalNavigation,
            replace: false,
            resetNestedNavState:
                !isLastNavConfig || isLastNavConfig && resetNestedNavStateOnLastPage,
            notifyNavUpdatesStreamListeners: isLastNavConfig,
          );
          break;
        case NavigationAction.pop:
          pop(
            notifyNavUpdatesStreamListeners: isLastNavConfig,
          );
          break;
        case NavigationAction.popToRoot:
          popToRoot(notifyNavUpdatesStreamListeners: isLastNavConfig);
          break;
      }
    }
  }

  void popToRoot({bool notifyNavUpdatesStreamListeners = true}) {
    while (_navInfoList.length > 1) {
      _pop(notifyNavUpdatesStreamListeners: notifyNavUpdatesStreamListeners);
    }
  }
}

@immutable
class NavigationConfig {
  const NavigationConfig({
    this.action = NavigationAction.push,
    this.pageName,
    this.globalNavigation = false,
  }) : assert(action != NavigationAction.push || pageName != null);

  factory NavigationConfig.pop() {
    return NavigationConfig(action: NavigationAction.pop);
  }

  final NavigationAction action;
  final PageName? pageName;
  final bool globalNavigation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationConfig &&
        other.action == action &&
        other.pageName == pageName &&
        other.globalNavigation == globalNavigation;
  }

  @override
  int get hashCode => action.hashCode ^ pageName.hashCode ^ globalNavigation.hashCode;
}

enum NavigationAction {
  push,
  pop,
  popToRoot,
}
