import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/carousel_poster_repository.dart';
import '../../domain/carousel_poster.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class CarouselEditViewModel extends ChangeNotifier {
  //▫️Constructor:
  CarouselEditViewModel({
    required CarouselPosterRepository carouselPosterRepository,
    required AccountSession accountSession,
  }) : _carouselPosterRepository = carouselPosterRepository,
       _accountSession = accountSession;

  //▫️Variables:
  // Repositories
  final CarouselPosterRepository _carouselPosterRepository;
  final AccountSession _accountSession;

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // File picker method to pick images for the carousel
  Future<Result<List<PlatformFile>?>> pickImage(List<Image> images) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to add images for the carousel.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      ); // Allow multiple images as long as it has memory

      // Criteria: Up to 15 images allowed for carousel image & must be less than 5 MB
      if (result != null) {
        if (result.files.length + images.length <= 15) {
          for (var file in result.files) {
            if (file.bytes == null && file.size > 5242880) {
              _errorMessage = "Maximum file size of 5 MB.";
              return Result.error(Exception(_errorMessage));
            }
          }
          return Result.ok(result.files);
        } else {
          _errorMessage = "Maximum of 15 images allowed.";
          return Result.error(Exception(_errorMessage));
        }
      } else {
        return Result.ok(null);
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      _errorMessage =
          "Unexpected error occurred during the image picking process, Please try again.";
      return Result.error(Exception(_errorMessage));
    }
  }

  // Add, update and delete images in the carousel
  Future<Result> saveChanges(
    List<File?> newFile,
    List<CarouselPoster> newCarousel,
    List<CarouselPoster> oldCarousel,
  ) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to add images for the carousel.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      for (var index = 0; index < newFile.length; index++) {
        if (newFile[index] != null) {
          final filePath = await _carouselPosterRepository.uploadImage(
            newFile[index]!,
          );

          // Create new carousel objects based on images uploaded
          switch (filePath) {
            case Ok<String>():
              newCarousel[index] = CarouselPoster(
                id: 0,
                image: filePath.value,
                placement: index,
                archived: true,
                updatedAt: DateTime.timestamp(),
              );
            case Error<String>():
              _errorMessage =
                  "There's an issue when trying to save uploaded images to the system. Please try again.";
              return filePath;
          }
        }
      }

      for (var index = 0; index < newCarousel.length; index++) {
        final poster = newCarousel[index];

        // Store new carousel images
        if (poster.archived) {
          final newPoster = CarouselPoster(
            id: 0,
            image: poster.image,
            placement: index + 1,
            archived: false,
            updatedAt: poster.updatedAt,
          );

          final saveResult = await _carouselPosterRepository.addCarouselPoster(
            newPoster,
          );
          if (saveResult is Error<CarouselPoster>) {
            _errorMessage =
                "There's an issue when the new order of carousel images were being saved to the system. Please try again.";
            return saveResult;
          }

          // Update placement of old carousel images
        } else {
          final updatedPoster = CarouselPoster(
            id: poster.id,
            image: poster.image,
            placement: index + 1,
            archived: false,
            updatedAt: poster.updatedAt,
          );

          final saveResult = await _carouselPosterRepository.editCarouselPoster(
            updatedPoster,
          );
          if (saveResult is Error<CarouselPoster>) {
            _errorMessage =
                "There's an issue when the new order of carousel images were being saved to the system. Please try again.";
            return saveResult;
          }
        }
      }

      // Archive old carousel images
      for (var index = 0; index < oldCarousel.length; index++) {
        final poster = oldCarousel[index];
        if (!newCarousel.contains(poster)) {
          final deletedPoster = CarouselPoster(
            id: poster.id,
            image: poster.image,
            placement: index + 1,
            archived: true,
            updatedAt: poster.updatedAt,
          );

          final deleteResult = await _carouselPosterRepository
              .editCarouselPoster(deletedPoster);
          if (deleteResult is Error<CarouselPoster>) {
            _errorMessage =
                "There's an issue when the new order of carousel images were being saved to the system. Please try again.";
            return deleteResult;
          }
        }
      }

      return Result.ok('Success');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
