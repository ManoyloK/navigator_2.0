part of 'pages.dart';

class _CustomMaterialPage<T> extends MaterialPage<T> {
  const _CustomMaterialPage({
    required Widget child,
    bool maintainState = true,
    LocalKey? key,
    String? name,
    String? restorationId,
    bool isFullscreenDialog = false,
    this.isModal = false,
    this.isModalDraggable = false,
    this.isModalDismissible = false,
  }) : super(
          child: child,
          maintainState: maintainState,
          fullscreenDialog: isFullscreenDialog,
          key: key,
          name: name,
          restorationId: restorationId,
        );

  final bool isModal;
  final bool isModalDraggable;
  final bool isModalDismissible;

  @override
  Route<T> createRoute(BuildContext context) {
    if (isModal) {
      return _CustomModalBottomSheetRoute(
        builder: (context) => child,
        settings: this,
        isDismissible: isModalDismissible,
        isDraggable: isModalDraggable,
        buildTransition: _buildTransitions,
      );
    } else if (fullscreenDialog) {
      return PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => child,
        settings: this,
        barrierColor: Colors.transparent,
        transitionsBuilder: _buildTransitions,
      );
    } else {
      return super.createRoute(context);
    }
  }

  @override
  int get hashCode => key.hashCode ^ child.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is _CustomMaterialPage) {
      return key == other.key && child == other.child;
    } else {
      return super == other;
    }
  }

  Widget _buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final custom = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 1, curve: Curves.easeOut),
    ));

    final backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 1, curve: Curves.linear),
    ));

    return Stack(
      children: [
        IgnorePointer(
          child: AnimatedBuilder(
            animation: backgroundOpacityAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(backgroundOpacityAnimation.value),
              );
            },
          ),
        ),
        SlideTransition(position: custom, child: child)
      ],
    );
  }
}

class _CustomModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _CustomModalBottomSheetRoute({
    required this.buildTransition,
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool isDraggable = true,
    bool isDismissible = true,
  }) : super(
          builder: builder,
          expanded: false,
          modalBarrierColor: Colors.transparent,
          settings: settings,
          enableDrag: isDraggable,
          isDismissible: isDismissible,
        );

  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) buildTransition;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      buildTransition(context, animation, secondaryAnimation, child);
}
