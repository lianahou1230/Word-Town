import 'package:flutter/material.dart';

class PageTurnTransition extends PageRouteBuilder {
  final Widget child;

  PageTurnTransition({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: curve,
              ),
            );

            return Stack(
              children: [
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Container(),
                ),
                SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}
