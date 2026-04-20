import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../../data/medical_record_repository.dart';
import '../../domain/medical_record.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class MedicalRecordViewModel extends ChangeNotifier {
  //▫️Constructor:
  MedicalRecordViewModel({
    required MedicalRecordRepository medicalRepository,
    required AccountSession accountSession,
  }) : _medicalRepository = medicalRepository,
       _accountSession = accountSession;

  //▫️Variables:
  final MedicalRecordRepository _medicalRepository;
  final AccountSession _accountSession;

  List<MedicalRecord> _medicalRecords = [];
  List<MedicalRecord> _searchedRecords = [];
  final Map<String, MedicalRecord> _searchList = {};

  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  List<MedicalRecord> get records => _searchedRecords;
  Map<String, MedicalRecord> get searchList => _searchList;
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  Future<Result> load(String? id) async {
    late final String userUID;
    final session = _accountSession.session;
    _errorMessage = null;

    // Determine if caller is admin so we pass the right flag
    final isAdmin = session is AdminSession;

    if (session is AdminSession && id != null) {
      userUID = id;
    } else if (session is UserSession) {
      userUID = session.userAccount.id;
    } else {
      _errorMessage =
          "There's an issue where there is no user to get medical records for. Try again later.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      // isAdmin=true → PHP returns all records (pending + verified)
      // isAdmin=false → PHP returns only verified records
      final result = await _medicalRepository.getMedicalRecords(
        userUID,
        isAdmin: isAdmin,
      );
      switch (result) {
        case Ok<List<MedicalRecord>>():
          _medicalRecords = result.value;
          sortData();
          createSearchList();
          _searchedRecords = List.from(_medicalRecords);
          debugPrint("Get medical records: ${result.value}");
        case Error<List<MedicalRecord>>():
          _errorMessage =
              "There's an issue in fetching medical record's data. Try again later.";
          debugPrint("Failed to get medical records: ${result.error}");
          return result;
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void createSearchList() {
    _searchList.clear();
    _searchList.addAll(
      Map.fromEntries(
        _medicalRecords.map(
          (r) => MapEntry(
            '${r.name} (${DateFormat('dd MMM yyyy').format(r.date)})',
            r,
          ),
        ),
      ),
    );
  }

  void sortData() {
    _medicalRecords.sort((a, b) => b.date.compareTo(a.date));
  }

  void searchPicked(MedicalRecord selected) {
    _searchedRecords.clear();
    _searchedRecords.add(selected);
    notifyListeners();
  }

  // Delete a user's record (admin)
  Future<Result> deleteRecord(MedicalRecord record) async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to delete medical record.";
      return Result.error(Exception(_errorMessage));
    }
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    final deleteRecord = MedicalRecord(
      id: record.id,
      name: record.name,
      date: record.date,
      file: record.file,
      userId: record.userId,
      archived: true,
      updatedAt: record.updatedAt,
    );

    try {
      final result = await _medicalRepository.editMedicalRecord(deleteRecord);
      switch (result) {
        case Ok<MedicalRecord>():
          debugPrint('Deleted record: ${result.value}');
        case Error<MedicalRecord>():
          _errorMessage = "Unable to archive ${record.name}. Please try again.";
          debugPrint('Failed to delete record: ${result.error}');
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Download and open PDF
  Future<Result> downloadAndOpenPDF(MedicalRecord recordData) async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session == null) {
      _errorMessage = "You must be logged in to view medical records.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final downloadResult = await _medicalRepository.downloadPDF(recordData);

      late final File file;
      switch (downloadResult) {
        case Ok<File>():
          file = downloadResult.value;
        case Error<File>():
          _errorMessage =
              "There's an issue in downloading the medical record PDF. Please try again.";
          debugPrint("Failed to download PDF: ${downloadResult.error}");
          return downloadResult;
      }

      final openResult = await OpenFile.open(file.path);

      if (openResult.type == ResultType.done) {
        return Result.ok('PDF opened successfully.');
      } else {
        _errorMessage =
            "No PDF viewer app found on device. Please install a PDF viewer and try again.";
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      debugPrint("Error opening PDF: $e");
      _errorMessage =
          "Unexpected error occurred while opening the medical record. Please try again.";
      return Result.error(Exception(_errorMessage));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
