import 'package:flutter/foundation.dart';

import 'index.dart';

@immutable
abstract class PageConfiguration {
  const PageConfiguration({
    required this.pageName,
    this.settings,
  });

  final PageName pageName;
  final Object? settings;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageConfiguration && other.pageName == pageName && other.settings == settings;
  }

  @override
  int get hashCode => pageName.hashCode ^ settings.hashCode;
}

@immutable
class PlainPageConfiguration extends PageConfiguration {
  const PlainPageConfiguration({
    required PageName pageName,
    Object? settings,
    this.isFullScreenDialog = false,
  }) : super(
          pageName: pageName,
          settings: settings,
        );

  final bool isFullScreenDialog;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlainPageConfiguration &&
        other.isFullScreenDialog == isFullScreenDialog &&
        super == other;
  }

  @override
  int get hashCode => isFullScreenDialog.hashCode ^ super.hashCode;
}

@immutable
class ModalPageConfiguration extends PageConfiguration {
  const ModalPageConfiguration({
    required PageName pageName,
    Object? settings,
    this.isDraggable = true,
    this.isDismissible = true,
  }) : super(
          pageName: pageName,
          settings: settings,
        );

  final bool isDraggable;
  final bool isDismissible;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModalPageConfiguration &&
        other.isDraggable == isDraggable &&
        other.isDismissible == isDismissible &&
        super == other;
  }

  @override
  int get hashCode => isDraggable.hashCode ^ isDismissible.hashCode ^ super.hashCode;
}
