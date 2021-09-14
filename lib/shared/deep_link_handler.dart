import 'package:navigator_20/navigation/index.dart';
import 'package:uni_links/uni_links.dart';

import 'deep_link_parser.dart';
import 'logger.dart';

class DeepLinkHandler {
  DeepLinkHandler(this._navigation) {
    uriLinkStream.listen(_parseDeepLink, onError: (Object err) {
      Log.instance.e('Failed to handle deeplink', err);
    });
  }
  final Navigation _navigation;

  void _parseDeepLink(Uri? uri) {
    if (uri != null) {
      final pages = DeepLinkParser.parse(uri);
      for (final page in pages) {
        _navigation.navigate(
          page,
          replace: true,
        );
      }
    }
  }
}
