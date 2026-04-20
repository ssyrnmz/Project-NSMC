import 'package:flutter/material.dart';

import '../../data/doctor_repository.dart';
import '../../data/speciality_repository.dart';
import '../../domain/doctor.dart';
import '../../domain/speciality.dart';
import '../../../../utils/data/results.dart';

class DoctorViewModel extends ChangeNotifier {
  //▫️Constructor:
  DoctorViewModel({
    required DoctorRepository doctorRepository,
    required SpecialityRepository specialityRepository,
  }) : _doctorRepository = doctorRepository,
       _specialityRepository = specialityRepository;

  //▫️Variables:
  // Repositories
  final DoctorRepository _doctorRepository;
  final SpecialityRepository _specialityRepository;

  // Repository datas
  List<Doctor> _doctors = [];
  List<Speciality> _speciality = [];
  final Map<String, int> _searchList = {};

  // For finding specific value fast
  Map<int, Speciality> _specialityMap = {};

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  List<Doctor> get doctors => _doctors;
  List<Speciality> get specialities => _speciality;
  Map<String, int> get searchList => _searchList;
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  // Get the speciality based on its ID
  Speciality? getSpeciality(int id) {
    return _specialityMap[id];
  }

  //▫️Functions:
  // Load data into lists
  Future<Result> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load specialities
      final specResult = await _specialityRepository.getSpecialities();

      switch (specResult) {
        case Ok<List<Speciality>>():
          _speciality = specResult.value;
          _specialityMap = {for (var s in _speciality) s.id: s};
          debugPrint("Get specialities: ${specResult.value}");
        case Error<List<Speciality>>():
          _errorMessage =
              "There's an issue in fetching doctor's data. Try again later.";
          debugPrint("Failed to get specialities: ${specResult.error}");
          return specResult;
      }

      // Load doctors
      final docResult = await _doctorRepository.getDoctors();

      switch (docResult) {
        case Ok<List<Doctor>>():
          _doctors = docResult.value;
          sortData();
          createSearchList();
          debugPrint("Get doctors: ${docResult.value}");
        case Error<List<Doctor>>():
          _errorMessage =
              "There's an issue in fetching doctor's data. Try again later.";
          debugPrint("Failed to get doctors: ${docResult.error}");
      }
      return docResult;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create the search list
  void createSearchList() {
    _searchList.clear();
    _searchList.addAll(
      Map.fromEntries(_doctors.map((d) => MapEntry(d.name, d.specialityId))),
    );
  }

  // Sort repository datas whenever cached
  void sortData() {
    _speciality.sort((a, b) => a.id.compareTo(b.id));
    _doctors.sort((a, b) {
      // Resident = 0 (top), Visiting = 1 (below), others = 2
      int _statusOrder(String s) {
        final lower = s.toLowerCase();
        if (lower == 'resident') return 0;
        if (lower == 'visiting') return 1;
        return 2;
      }
      final statusCmp = _statusOrder(a.status).compareTo(_statusOrder(b.status));
      if (statusCmp != 0) return statusCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  // Create and return a list of doctors based on speciality
  List<Doctor> doctorList(Speciality? s) {
    if (s == null) return [];
    final list = _doctors.where((d) => d.specialityId == s.id).toList();
    // Already sorted by sortData(), but re-sort per speciality for safety
    list.sort((a, b) {
      int _statusOrder(String s) {
        final lower = s.toLowerCase();
        if (lower == 'resident') return 0;
        if (lower == 'visiting') return 1;
        return 2;
      }
      final statusCmp = _statusOrder(a.status).compareTo(_statusOrder(b.status));
      if (statusCmp != 0) return statusCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }
}
