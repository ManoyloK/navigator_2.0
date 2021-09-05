import 'package:flutter/material.dart';
import 'package:navigator_20/pages/catalog_tabs.dart';
import 'package:navigator_20/pages/index.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'page_configuration.dart';
part 'custom_material_page.dart';

enum PageName {
  root,
  home,
  catalog,
  details,
  dialog,
  tabA,
  tabB,
  tabC,
}

class PageFactory {
  PageFactory();

  MaterialPage create(PageConfiguration pageConfig) {
    Widget screen;
    String screenName;

    switch (pageConfig.pageName) {
      case PageName.root:
        screen = const RootPage();
        screenName = '';
        break;
      case PageName.home:
        screen = const HomePage();
        screenName = 'home';
        break;
      case PageName.catalog:
        screen = const CatalogPage();
        screenName = 'catalog';
        break;
      case PageName.details:
        screen = const Details();
        screenName = 'details';
        break;
      case PageName.dialog:
        screen = const AppDialog();
        screenName = 'dialog';
        break;
      case PageName.tabA:
        screen = const TabA();
        screenName = 'tabA';
        break;
      case PageName.tabB:
        screen = const TabB();
        screenName = 'tabB';
        break;
      case PageName.tabC:
        screen = const TabC();
        screenName = 'tabC';
        break;
    }

    return _wrapInPageWithRoute(pageConfig, screenName, screen);
  }

  MaterialPage _wrapInPageWithRoute(
    PageConfiguration pageConfig,
    String screenName,
    Widget child,
  ) {
    if (pageConfig is ModalPageConfiguration) {
      return _CustomMaterialPage<Page>(
        child: child,
        name: screenName,
        key: ValueKey(screenName),
        isModal: true,
        isModalDraggable: pageConfig.isDraggable,
        isModalDismissible: pageConfig.isDismissible,
      );
    } else {
      return _CustomMaterialPage<Page>(
        child: child,
        name: screenName,
        key: ValueKey(screenName),
        isFullscreenDialog: (pageConfig as PlainPageConfiguration).isFullScreenDialog,
      );
    }
  }
}
