import 'package:navigator_20/navigation/index.dart';

class DeepLinkParser {
  static List<PageConfiguration> parse(Uri uri) {
   
    final pages = <PageConfiguration>[];

    if (uri.pathSegments[0] == 'home') {
      pages.add(const PlainPageConfiguration(pageName: PageName.home));
      if (uri.pathSegments.length > 1) {
        pages.add(const PlainPageConfiguration(pageName: PageName.details));
      }
    }
    if (uri.pathSegments[0] == 'catalog') {
      pages.add(const PlainPageConfiguration(pageName: PageName.catalog));
      PageName activeTab;
      if (uri.pathSegments.length > 1) {
        if (uri.pathSegments[1] == 'a') {
          activeTab = PageName.tabA;
        } else if (uri.pathSegments[1] == 'b') {
          activeTab = PageName.tabB;
        } else {
          activeTab = PageName.tabC;
        }
        pages.add(PlainPageConfiguration(pageName: activeTab));
      }

      if (uri.pathSegments.length > 2 && uri.pathSegments[2] == 'details') {
        pages.add(const PlainPageConfiguration(pageName: PageName.details));
      }
    }

    return pages;
  }
}
