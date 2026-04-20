import 'dart:io';
import 'dart:convert';

import '../domain/carousel_poster.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class CarouselPosterService {
  // Constructor
  CarouselPosterService({required ApiClient apiClient})
    : _apiClient = apiClient;

  // Variables
  final ApiClient _apiClient;
  final String _path = 'health_screening/';

  // Functions:
  // Retrieve all carousel posters (GET)
  Future<Result<List<CarouselPoster>>> getCarouselPosters(
    DateTime? sync,
  ) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_carousel_posters.php?sync=${sync.toIso8601String()}'
          : '${_path}get_carousel_posters.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.none);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final poster = parsed
            .map<CarouselPoster>((json) => CarouselPoster.fromJson(json))
            .toList();

        return Result.ok(poster);
      } else {
        return Result.error(
          Exception(
            'Invalid Response: ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Store a new carousel poster (POST)
  Future<Result<CarouselPoster>> addCarouselPoster(
    CarouselPoster poster,
  ) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_carousel_poster.php',
        body: poster.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(poster);
      } else {
        return Result.error(
          Exception(
            'Invalid Response: ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Replace a carousel poster with updated details (POST)
  Future<Result<CarouselPoster>> editCarouselPoster(
    CarouselPoster poster,
  ) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_carousel_poster.php',
        body: poster.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(poster);
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Save image into the server first and receive path (POST)
  Future<Result<String>> saveImageToFile(File image) async {
    try {
      final response = await _apiClient.postFile(
        '${_path}save_image_carousel_poster.php',
        item: image,
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        final filePath = json.decode(response.body);
        return Result.ok('${_apiClient.baseUrl}$filePath');
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
