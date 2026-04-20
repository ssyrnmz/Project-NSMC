import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../utils/ui/show_delete_confirmation_dialogue.dart';

// Carousel Widget for Display
class ImageCarousel extends StatefulWidget {
  final bool autoPlay;
  final bool showIcon;
  final List<Image> images;
  final VoidCallback? onDelete;
  final bool hideIndicator;

  const ImageCarousel({
    super.key,
    this.autoPlay = false,
    this.showIcon = false,
    required this.images,
    this.onDelete,
    this.hideIndicator = false,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _activePage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) startTimer();
  }

  void startTimer() {
    if (widget.images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;

      int nextPage = _activePage + 1;
      if (nextPage >= widget.images.length) {
        nextPage = 0;
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay) {
      _timer?.cancel();
      if (widget.autoPlay) {
        startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // This ClipRRect applies the 12.0 radius to the PageView and the image it contains.
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => _activePage = value),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // FIX APPLIED HERE: Positioned.fill ensures the image fills the entire
                    // stack area (the 16:9 AspectRatio box), eliminating the blank space.
                    Positioned.fill(child: widget.images[index]),

                    // Delete Icon Button
                    if (widget.showIcon)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            showDeleteConfirmationDialog(
                              context: context,
                              title: "Delete Item",
                              message:
                                  "Are you sure you want to delete this item? This action cannot be undone.",
                              confirmButtonText: "Yes, Delete",
                              showSuccessDialog: false,
                              onDelete: () async {
                                widget.onDelete!();

                                if (!mounted) return;

                                return; // Add this line
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),

        // This SizedBox controls the space between the image container and the dots.
        const SizedBox(height: 12),

        // Bottom indicator dots (conditionally show)
        if (!widget.hideIndicator && widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _activePage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _activePage == index
                          ? const Color(0xFF4D7C4A)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
