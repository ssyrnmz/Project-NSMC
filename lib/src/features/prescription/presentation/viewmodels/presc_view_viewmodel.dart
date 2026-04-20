// Info: ViewModel for viewing and searching prescriptions.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/prescription_repository.dart';
import '../../domain/prescription.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class PrescriptionViewModel extends ChangeNotifier {
  //▫️Constructor
  PrescriptionViewModel({
    required PrescriptionRepository prescriptionRepository,
    required AccountSession accountSession,
  })  : _prescriptionRepository = prescriptionRepository,
        _accountSession = accountSession;

  //▫️Variables
  final PrescriptionRepository _prescriptionRepository;
  final AccountSession _accountSession;

  List<Prescription> _prescriptions = [];
  List<Prescription> _searchedPrescriptions = [];
  final Map<String, Prescription> _searchList = {};

  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  List<Prescription> get prescriptions => _searchedPrescriptions;
  List<Prescription> get currentPrescriptions =>
      _searchedPrescriptions.where((p) => p.status == 'current').toList();
  List<Prescription> get historyPrescriptions =>
      _searchedPrescriptions.where((p) => p.status == 'history').toList();
  Map<String, Prescription> get searchList => _searchList;
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions
  // Load prescriptions for a user
  Future<Result> load(String? id) async {
    late final String userUID;
    final session = _accountSession.session;
    _errorMessage = null;

    if (session is AdminSession && id != null) {
      userUID = id;
    } else if (session is UserSession) {
      userUID = session.userAccount.id;
    } else {
      _errorMessage =
          "There's an issue where there is no user to get prescriptions for. Try again later.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _prescriptionRepository.getPrescriptions(userUID);
      switch (result) {
        case Ok<List<Prescription>>():
          _prescriptions = result.value;
          _sortData();
          _createSearchList();
          _searchedPrescriptions = List.from(_prescriptions);
          debugPrint("Get prescriptions: ${result.value.length} items");
        case Error<List<Prescription>>():
          _errorMessage =
              "There's an issue in fetching prescription data. Try again later.";
          debugPrint("Failed to get prescriptions: ${result.error}");
          return result;
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all prescriptions (admin)
  Future<Result> loadAll() async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session is! AdminSession) {
      _errorMessage = "Only admins can view all prescriptions.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot access prescription data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing prescription information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _prescriptionRepository.getAllPrescriptions();
      switch (result) {
        case Ok<List<Prescription>>():
          _prescriptions = result.value;
          _sortData();
          _createSearchList();
          _searchedPrescriptions = List.from(_prescriptions);
        case Error<List<Prescription>>():
          _errorMessage =
              "There's an issue in fetching prescriptions. Try again later.";
          return result;
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Build search list with formatted keys
  void _createSearchList() {
    _searchList.clear();
    _searchList.addAll(
      Map.fromEntries(
        _prescriptions.map(
          (p) => MapEntry(
            DateFormat('dd MMM yyyy').format(p.prescribedDate),
            p,
          ),
        ),
      ),
    );
  }

  // Sort prescriptions by date descending
  void _sortData() {
    _prescriptions.sort(
        (a, b) => b.prescribedDate.compareTo(a.prescribedDate));
  }

  // Select a searched item
  void searchPicked(Prescription selected) {
    _searchedPrescriptions = [selected];
    notifyListeners();
  }

  // Reset search to show all
  void clearSearch() {
    _searchedPrescriptions = List.from(_prescriptions);
    notifyListeners();
  }
}
