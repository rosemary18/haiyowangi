import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

renderFadeTransition(Widget child) {
  return (BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      barrierDismissible: true,
      barrierColor: Colors.black38,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  };
}

renderSlideTransition(Widget child, {Offset beginOffset = const Offset(1.0, 0.0)}) {
  return (BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      barrierDismissible: true,
      barrierColor: Colors.black38,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        // Tween untuk posisi
        var slideTween = Tween(begin: beginOffset, end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));
        var slideAnimation = animation.drive(slideTween);

        // Tween untuk opacity
        var opacityTween = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut));
        var opacityAnimation = animation.drive(opacityTween);

        // Tween untuk opacity saat keluar
        var reverseOpacityTween = Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut));
        var reverseOpacityAnimation = secondaryAnimation.drive(reverseOpacityTween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: reverseOpacityAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  };
}
