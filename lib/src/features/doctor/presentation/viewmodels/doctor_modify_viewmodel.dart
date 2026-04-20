import 'package:flutter/material.dart';

import '../../data/doctor_repository.dart';
import '../../domain/doctor.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class DoctorModifyViewModel extends ChangeNotifier {
  //▫️Constructor:
  DoctorModifyViewModel({
    required DoctorRepository doctorRepository,
    required AccountSession accountSession,
  }) : _doctorRepository = doctorRepository,
       _accountSession = accountSession;

  //▫️Variables:
  // Repositories
  final DoctorRepository _doctorRepository;
  final AccountSession _accountSession;

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // Create doctor based on input
  Future<Result> addDoctor(Doctor doc) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to create doctor information.";
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
      final result = await _doctorRepository.addDoctor(doc);
      switch (result) {
        case Ok<Doctor>():
          debugPrint("Add doctor: ${result.value}");
        case Error<Doctor>():
          _errorMessage =
              "There's a system issue during creation of ${doc.name}'s data. Please try again or check for issues surrounding application.";
          debugPrint("Failed to add doctor: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update doctor's detail with updated details
  Future<Result> editDoctor(Doctor doc) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to edit doctor information.";
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
      final result = await _doctorRepository.editDoctor(doc);
      switch (result) {
        case Ok<Doctor>():
          debugPrint("Updated doctor: ${result.value}");
        case Error<Doctor>():
          _errorMessage =
              "There's a system issue during update of ${doc.name}'s data. Please try again or check for issues surrounding application.";
          debugPrint("Failed to update doctor: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete/archive doctor's details
  Future<Result> deleteDoctor(Doctor doc) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to edit doctor information.";
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

    Doctor deleteDoctor = Doctor(
      id: doc.id,
      name: doc.name,
      status: doc.status,
      qualifications: doc.qualifications,
      specialization: doc.specialization,
      image: doc.image,
      specialityId: doc.specialityId,
      archived: true,
      updatedAt: doc.updatedAt,
    );

    try {
      final result = await _doctorRepository.editDoctor(deleteDoctor);
      switch (result) {
        case Ok<Doctor>():
          debugPrint("Deleted doctor: ${result.value}");
        case Error<Doctor>():
          _errorMessage =
              "There's a system issue during deletion of ${doc.name}'s data. Please try again or check for issues surrounding application.";
          debugPrint("Failed to delete doctor: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
