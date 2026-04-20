import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

// Animation used for transitioning between screens
// The duration can be changed for all screen transitions or for a specific screen
enum TransitionOption { horizontal, vertical, scaled }

// Basic transition animation between screens
PageRoute<T> transitionAnimation<T>({
  required Widget page,
  int durationMs = 700,
  int reverseDurationMs = 700,
  RouteSettings? route,
  TransitionOption type = TransitionOption
      .horizontal, // Change Horizontal or Scaled in the specific file instead
}) {
  return PageRouteBuilder<T>(
    settings: route,
    transitionDuration: Duration(milliseconds: durationMs),
    reverseTransitionDuration: Duration(milliseconds: reverseDurationMs),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final transitionType = switch (type) {
        TransitionOption.horizontal => SharedAxisTransitionType.horizontal,
        TransitionOption.vertical => SharedAxisTransitionType.vertical,
        TransitionOption.scaled => SharedAxisTransitionType.scaled,
      };

      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType,
        child: child,
      );
    },
  );
}

// Extra animations if required (same implementation as basic transition)
PageRoute<T> transitionFadeThrough<T>({
  required Widget page,
  int durationMs = 500,
  int reverseDurationMs = 500,
  RouteSettings? route,
}) {
  return PageRouteBuilder<T>(
    settings: route,
    transitionDuration: Duration(milliseconds: durationMs),
    reverseTransitionDuration: Duration(milliseconds: reverseDurationMs),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}

PageRoute<T> transitionFadeScale<T>({
  required Widget page,
  int durationMs = 500,
  int reverseDurationMs = 500,
  RouteSettings? route,
}) {
  return PageRouteBuilder<T>(
    settings: route,
    transitionDuration: Duration(milliseconds: durationMs),
    reverseTransitionDuration: Duration(milliseconds: reverseDurationMs),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeScaleTransition(animation: animation, child: child);
    },
  );
}
