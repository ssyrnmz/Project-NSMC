import 'package:flutter/material.dart';

import '../../data/carousel_poster_repository.dart';
import '../../data/health_screening_repository.dart';
import '../../domain/carousel_poster.dart';
import '../../domain/health_screening.dart';
import '../../../../utils/data/results.dart';

class HealthScreeningViewModel extends ChangeNotifier {
  //▫️Constructor:
  HealthScreeningViewModel({
    required HealthScreeningRepository healthScreeningRepository,
    required CarouselPosterRepository carouselPosterRepository,
  }) : _healthScreeningRepository = healthScreeningRepository,
       _carouselPosterRepository = carouselPosterRepository;

  //▫️Variables:
  // Repositories
  final HealthScreeningRepository _healthScreeningRepository;
  final CarouselPosterRepository _carouselPosterRepository;

  // Repository datas (Health Screening & Carousel Images)
  List<HealthScreening> _hsPackages = [];
  List<HealthScreening> _filteredPackages = [];

  List<CarouselPoster> _cPosters = [];
  List<Image> _imagePosters = [];

  final Map<String, HealthScreening> _searchList = {};

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  List<HealthScreening> get packages => _hsPackages;
  List<HealthScreening> get filteredPackages => _filteredPackages;
  List<CarouselPoster> get posters => _cPosters;
  List<Image> get images => _imagePosters;
  Map<String, HealthScreening> get searchList => _searchList;
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  // Returns unique category list from loaded packages (for filter chips)
  List<String> get categories {
    final cats = _hsPackages
        .map((p) => p.category)
        .whereType<String>()
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  //▫️Functions:
  // Load data into lists
  Future<Result> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load carousel images
      final cpResult = await _carouselPosterRepository.getCarouselPosters();
      switch (cpResult) {
        case Ok<List<CarouselPoster>>():
          _cPosters = cpResult.value;

          // Empty = 1 Default Image
          if (_cPosters.isEmpty) {
            _imagePosters.add(
              Image.asset('assets/images/noPackagesScreen.png'),
            );
          }
          debugPrint("Get carousel images: ${cpResult.value}");
        case Error<List<CarouselPoster>>():
          _errorMessage =
              "There's an issue in fetching promotions and information. Try again later.";
          debugPrint("Failed to get carousel images: ${cpResult.error}");
          return cpResult;
      }

      // Load health screening packages
      final hspResult = await _healthScreeningRepository.getHealthScreenings();
      switch (hspResult) {
        case Ok<List<HealthScreening>>():
          _hsPackages = hspResult.value;
          sortData();
          createSearchList();
          _filteredPackages = List.from(_hsPackages);
          debugPrint("Get health screenings: ${hspResult.value}");
        case Error<List<HealthScreening>>():
          _errorMessage =
              "There's an issue in fetching health screening's data. Try again later.";
          debugPrint("Failed to get health screenings: ${hspResult.error}");
      }

      return hspResult;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create search list to be used
  void createSearchList() {
    _searchList.clear();
    _searchList.addAll(
      Map.fromEntries(_hsPackages.map((hsp) => MapEntry(hsp.name, hsp))),
    );
  }

  // Sort repository datas whenever cached
  void sortData() {
    _hsPackages.sort((a, b) => a.id.compareTo(b.id));
    _cPosters.sort((a, b) => a.placement.compareTo(b.placement));
    _imagePosters = _cPosters
        .map((p) => convertImage(p.image))
        .toList(); // Create image list only after data sorted
  }

  // Convert URL String into image
  Image convertImage(String image) {
    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: Text(
            "Image Asset Not Found.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        );
      },
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: CircularProgressIndicator(color: Color(0xFF7CB342)),
        );
      },
    );
  }

  // Filter packages based on sort and/or category chosen
  void filterOut(String? sort, {String? category}) {
    // Start from full list or category-filtered list
    List<HealthScreening> base = (category != null && category.isNotEmpty)
        ? _hsPackages
            .where((p) => p.category == category)
            .toList()
        : List.from(_hsPackages);

    _filteredPackages.clear();

    if (sort == 'Price: Low to High') {
      base.sort((a, b) => a.price.compareTo(b.price));
      _filteredPackages.addAll(base);
    } else if (sort == 'Price: High to Low') {
      base.sort((a, b) => b.price.compareTo(a.price));
      _filteredPackages.addAll(base);
    } else {
      _filteredPackages.addAll(base);
    }

    notifyListeners();
  }
}