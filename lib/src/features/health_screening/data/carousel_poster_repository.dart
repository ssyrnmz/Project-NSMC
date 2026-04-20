import 'dart:io';

import 'carousel_poster_service.dart';
import '../domain/carousel_poster.dart';
import '../../../utils/data/results.dart';

class CarouselPosterRepository {
  //▫️Constructor:
  CarouselPosterRepository({
    required CarouselPosterService carouselPosterService,
  }) : _carouselPosterService = carouselPosterService;

  //▫️Variables:
  final CarouselPosterService _carouselPosterService;
  DateTime? _lastSync;
  List<CarouselPoster> _cache = [];

  //▫️Functions:
  // Get carousel images
  Future<Result<List<CarouselPoster>>> getCarouselPosters() async {
    final result = await _carouselPosterService.getCarouselPosters(_lastSync);

    switch (result) {
      case Ok<List<CarouselPoster>>():
        final images = result.value;

        // Only updates when there is new data after last synced
        if (images.isNotEmpty) {
          _updateCache(images);
          _lastSync = images.first.updatedAt;
        }

        return Result.ok(_cache);
      case Error<List<CarouselPoster>>():
        return Result.error(result.error);
    }
  }

  // Add a new image and their information
  Future<Result<CarouselPoster>> addCarouselPoster(CarouselPoster image) async {
    final result = await _carouselPosterService.addCarouselPoster(image);
    return result;
  }

  // Update an image's information or archive it
  Future<Result<CarouselPoster>> editCarouselPoster(
    CarouselPoster image,
  ) async {
    final result = await _carouselPosterService.editCarouselPoster(image);

    // Updates cache when the operation was successful
    if (result is Ok<CarouselPoster>) {
      // Image is archived/deleted
      if (image.archived) {
        _cache.removeWhere((img) => img.id == image.id);
        _lastSync = result.value.updatedAt;
      }
    }
    return result;
  }

  // Save the image file of carousel poster
  Future<Result<String>> uploadImage(File image) async {
    return await _carouselPosterService.saveImageToFile(image);
  }

  //▫️Helpers:
  // Update cache by adding new data, replace old data with updated details
  void _updateCache(List<CarouselPoster> images) {
    if (_cache.isNotEmpty) {
      for (final data in images) {
        final index = _cache.indexWhere(
          (img) => img.id == data.id,
        ); // Check if there are the same object, returns its index from the cache list

        if (index != -1) {
          _cache[index] = data; // Update existing image
        } else {
          _cache.add(data); // Add new image
        }
      }
    } else {
      _cache = List.from(images); // No cache/first initialization of app
    }
  }
}
