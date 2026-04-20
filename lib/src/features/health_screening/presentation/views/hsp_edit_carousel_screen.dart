import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'widgets/image_carousel.dart';
import '../viewmodels/carousel_edit_viewmodel.dart';
import '../viewmodels/hsp_view_viewmodel.dart';
import '../../domain/carousel_poster.dart';
import '../../../../core/widgets/add_button.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';

class EditCarouselImageScreen extends StatefulWidget {
  const EditCarouselImageScreen({super.key});

  @override
  State<EditCarouselImageScreen> createState() =>
      _EditCarouselImageScreenState();
}

class _EditCarouselImageScreenState extends State<EditCarouselImageScreen> {
  //▫️Variables
  late List<CarouselPoster> _backupPosters;
  late List<CarouselPoster> _currentPosters;

  // List to store images for carousel display purposes
  final List<Image> _mainImages = [];

  // List to store new images temporarily before being stored in server uploads
  final List<File?> _newImages = [];

  //▫️State initialization:
  @override
  void initState() {
    super.initState();
    final vmInitial = context.read<HealthScreeningViewModel>();

    _backupPosters = List.from(vmInitial.posters);
    _currentPosters = List.from(vmInitial.posters);

    for (final c in _backupPosters) {
      _mainImages.add(vmInitial.convertImage(c.image)); // Store actual images
      _newImages.add(
        null,
      ); // Store empty values for existing images, store value of file image if there's a new image added
    }
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<CarouselEditViewModel>();
    final vmData = context.read<HealthScreeningViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf9fafb),
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF6FBF73),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit Carousel Images',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE6E6E6), height: 1),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "  Add Images",
                        style: GoogleFonts.poppins(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF404040),
                        ),
                      ),
                      AddButton(
                        onTap: () async {
                          // Button's function to upload image
                          final result = await vmModify.pickImage(_mainImages);

                          if (!context.mounted) return;

                          switch (result) {
                            case Ok<List<PlatformFile>?>():
                              final files = result.value;
                              late final String message;

                              // File picked or cancelled
                              if (files != null) {
                                setState(() {
                                  for (var file in files) {
                                    _mainImages.add(Image.memory(file.bytes!));
                                    _currentPosters.add(
                                      CarouselPoster(
                                        id: 0,
                                        image: 'new',
                                        placement: 0,
                                        archived: false,
                                        updatedAt: DateTime.timestamp(),
                                      ),
                                    );
                                    _newImages.add(File(file.path!));
                                  }
                                });

                                message = "Images successfully picked.";
                              } else {
                                message = "No images were picked.";
                              }

                              showSnackBar(context: context, text: message);
                            case Error<List<PlatformFile>?>():
                              showSnackBar(
                                context: context,
                                text:
                                    vmModify.message ??
                                    "An unknown error occured. Please try again.",
                                color: Colors.red[900],
                              );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Image Guidelines",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "• Size: 1920 × 1080 px  (16/9)\n"
                          "• Format: JPG or PNG\n"
                          "• Max file size: 5 MB",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF616161),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "  Carousel Images",
                    style: GoogleFonts.poppins(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF404040),
                    ),
                  ),
                  const SizedBox(height: 0),
                ]),
              ),
            ),

            SliverReorderableList(
              itemBuilder: (context, index) {
                return Container(
                  key: ValueKey(_mainImages[index]),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Stack(
                    children: [
                      ImageCarousel(
                        autoPlay: false,
                        showIcon: true,
                        images: [_mainImages[index]],
                        onDelete: () {
                          setState(() {
                            _mainImages.removeAt(index);
                            _currentPosters.removeAt(index);
                            _newImages.removeAt(index);
                          });
                        },
                        hideIndicator: true,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.drag_handle,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: _mainImages.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // Item at old index deleted, list changed, and current new index would be invalid unless decremented
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _mainImages.removeAt(oldIndex);
                  final value = _currentPosters.removeAt(oldIndex);
                  final file = _newImages.removeAt(oldIndex);

                  _mainImages.insert(newIndex, item);
                  _currentPosters.insert(newIndex, value);
                  _newImages.insert(newIndex, file);
                });
              },
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Save new changes made on carousel list
                      final result = await vmModify.saveChanges(
                        _newImages,
                        _currentPosters,
                        _backupPosters,
                      );

                      if (!context.mounted) return;

                      switch (result) {
                        case Ok():
                          showSuccessDialog(
                            context: context,
                            title: "Changes on Carousel Poster Saved!",
                            message:
                                "The changes to the carousel image have been successfully saved.",
                            onButtonPressed: () {
                              vmData.load();

                              Navigator.of(context).popUntil((route) {
                                return route.settings.name == '/packageList' ||
                                    route.isFirst;
                              });
                            },
                          );

                        case Error():
                          showSnackBar(
                            context: context,
                            text:
                                vmModify.message ??
                                "An unknown error occured. Please try again.",
                            color: Colors.red[900],
                          );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FBF73),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Save Changes",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
