import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.loadingIndicator = true,
    required this.child,
  });

  final bool isLoading;
  final bool loadingIndicator;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(absorbing: isLoading, child: child),
        if (isLoading)
          Positioned.fill(
            child: (loadingIndicator)
                // Show loading spinner and make screen transparent
                ? Container(
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF629E5C),
                      ),
                    ),
                  )
                // Only makes screen transparent
                : Container(color: Colors.white.withOpacity(0.25)),
          ),
      ],
    );
  }
}
