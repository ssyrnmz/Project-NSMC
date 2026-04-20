// Info: ViewModel for creating, editing, and deleting prescriptions (admin).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/prescription_repository.dart';
import '../../domain/prescription.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class PrescriptionModifyViewModel extends ChangeNotifier {
  //▫️Constructor
  PrescriptionModifyViewModel({
    required PrescriptionRepository prescriptionRepository,
    required AccountSession accountSession,
  })  : _prescriptionRepository = prescriptionRepository,
        _accountSession = accountSession;

  //▫️Variables
  final PrescriptionRepository _prescriptionRepository;
  final AccountSession _accountSession;

  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  // ── Role guard helper ──────────────────────────────────────────────────────
  String? _checkAdminAccess() {
    final session = _accountSession.session;
    if (session is! AdminSession) {
      return "Only admins are allowed to manage prescriptions.";
    }
    if (session.adminAccount.role == 'Receptionist') {
      return "Your access level does not allow managing prescription information.";
    }
    return null; // OK
  }

  //▫️Functions

  // NEW: Open file picker to let admin select a PDF prescription file
  Future<Result<File?>> pickPDF() async {
    _errorMessage = null;
    final roleError = _checkAdminAccess();
    if (roleError != null) {
      _errorMessage = roleError;
      return Result.error(Exception(_errorMessage));
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          return Result.ok(File(path));
        } else {
          _errorMessage = "Could not retrieve file path. Please try again.";
          return Result.error(Exception(_errorMessage));
        }
      } else {
        return Result.ok(null); // user cancelled
      }
    } catch (e) {
      _errorMessage =
          "Unexpected error during file picking. Please try again.";
      debugPrint("PDF pick error: $e");
      return Result.error(Exception(_errorMessage));
    }
  }

  // Add a new prescription (admin only)
  // [pdfFile] is optional — if supplied it is uploaded first, then linked.
  Future<Result<Prescription>> addPrescription(
    Prescription prescription, {
    File? pdfFile,
  }) async {
    _errorMessage = null;
    final roleError = _checkAdminAccess();
    if (roleError != null) {
      _errorMessage = roleError;
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: upload PDF if supplied
      String? filename;
      if (pdfFile != null) {
        final uploadResult =
            await _prescriptionRepository.uploadPDF(pdfFile);
        switch (uploadResult) {
          case Ok<String>():
            filename = uploadResult.value;
            debugPrint('Uploaded prescription PDF: $filename');
          case Error<String>():
            _errorMessage =
                "Failed to upload the prescription file. Please try again.";
            return Result.error(uploadResult.error);
        }
      }

      // Step 2: save prescription with (optional) file reference
      final prescriptionWithFile = Prescription(
        id: prescription.id,
        prescribedDate: prescription.prescribedDate,
        doctorName: prescription.doctorName,
        doctorNotes: prescription.doctorNotes,
        medications: prescription.medications,
        status: prescription.status,
        userId: prescription.userId,
        updatedAt: prescription.updatedAt,
        prescriptionFile: filename ?? prescription.prescriptionFile,
      );

      final result = await _prescriptionRepository
          .addPrescription(prescriptionWithFile);
      switch (result) {
        case Ok<Prescription>():
          debugPrint("Added prescription: ${result.value.id}");
        case Error<Prescription>():
          _errorMessage =
              "Unable to add prescription. Please try again or check your connection.";
          debugPrint("Failed to add prescription: ${result.error}");
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit an existing prescription (admin only)
  // [pdfFile] is optional — if supplied, uploads and replaces existing file.
  Future<Result<Prescription>> editPrescription(
    Prescription prescription, {
    File? pdfFile,
  }) async {
    _errorMessage = null;
    final roleError = _checkAdminAccess();
    if (roleError != null) {
      _errorMessage = roleError;
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: upload new PDF if a replacement was chosen
      String? newFilename;
      if (pdfFile != null) {
        final uploadResult =
            await _prescriptionRepository.uploadPDF(pdfFile);
        switch (uploadResult) {
          case Ok<String>():
            newFilename = uploadResult.value;
            debugPrint('Uploaded replacement PDF: $newFilename');
          case Error<String>():
            _errorMessage =
                "Failed to upload the prescription file. Please try again.";
            return Result.error(uploadResult.error);
        }
      }

      // Step 2: edit prescription (keep existing file if no new one was picked)
      final prescriptionWithFile = Prescription(
        id: prescription.id,
        prescribedDate: prescription.prescribedDate,
        doctorName: prescription.doctorName,
        doctorNotes: prescription.doctorNotes,
        medications: prescription.medications,
        status: prescription.status,
        userId: prescription.userId,
        updatedAt: prescription.updatedAt,
        prescriptionFile:
            newFilename ?? prescription.prescriptionFile,
      );

      final result = await _prescriptionRepository
          .editPrescription(prescriptionWithFile);
      switch (result) {
        case Ok<Prescription>():
          debugPrint("Edited prescription: ${result.value.id}");
        case Error<Prescription>():
          _errorMessage =
              "Unable to update prescription. Please try again or check your connection.";
          debugPrint("Failed to edit prescription: ${result.error}");
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a prescription (admin only)
  Future<Result<void>> deletePrescription(int id) async {
    _errorMessage = null;
    final roleError = _checkAdminAccess();
    if (roleError != null) {
      _errorMessage = roleError;
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _prescriptionRepository.deletePrescription(id);
      switch (result) {
        case Ok<void>():
          debugPrint("Deleted prescription id: $id");
        case Error<void>():
          _errorMessage =
              "Unable to delete prescription. Please try again or check your connection.";
          debugPrint("Failed to delete prescription: ${result.error}");
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
