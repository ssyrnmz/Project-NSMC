import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/medical_record_repository.dart';
import '../../domain/medical_record.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class MedicalRecordUploadViewModel extends ChangeNotifier {
  //▫️Constructor:
  MedicalRecordUploadViewModel({
    required MedicalRecordRepository medicalRepository,
    required AccountSession accountSession,
  }) : _medicalRepository = medicalRepository,
       _accountSession = accountSession;

  //▫️Variables:
  final MedicalRecordRepository _medicalRepository;
  final AccountSession _accountSession;

  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // PDF file picker function
  Future<Result<File?>> pickPDF() async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to pick image for packages";
      return Result.error(Exception(_errorMessage));
    }
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;

        if (filePath != null) {
          return Result.ok(File(filePath));
        } else {
          _errorMessage =
              "The system could not retrieve file's path. Please try again.";
          return Result.error(Exception(_errorMessage));
        }
      } else {
        return Result.ok(null);
      }
    } catch (e) {
      debugPrint("File picker error: $e");
      _errorMessage =
          "Unexpected error occurred during the file picking process, Please try again.";
      return Result.error(Exception(_errorMessage));
    }
  }

  // Create medical record and notify ITD for verification
  //
  // FLOW:
  //   1. Upload PDF to server → get file path
  //   2. Save record to DB (record_verified = 0 by default)
  //   3. Send email to portal@normah.com with patient + record details
  //   4. Admin sees success — patient cannot see the record yet
  //   5. ITD clicks verify link in email → record_verified = 1
  //   6. Patient can now see the record in the app
  Future<Result> createRecord(
    MedicalRecord rec,
    File pdf, {
    required String patientName,
    required String patientEmail,
    required String patientIc,
  }) async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to upload medical record file.";
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

    try {
      // ── Step 1: Upload PDF to server ────────────────────────────────────
      final pdfResult = await _medicalRepository.uploadFile(pdf);

      switch (pdfResult) {
        case Ok<String>():
          debugPrint('Saved PDF: ${pdfResult.value}');
        case Error<String>():
          _errorMessage =
              "There's an issue when trying to save record PDF to the system. Please try again.";
          debugPrint('Failed to save PDF: ${pdfResult.error}');
          return pdfResult;
      }

      // ── Step 2: Save record to DB (verified = 0 by default) ─────────────
      final newRec = MedicalRecord(
        id: 0,
        name: rec.name,
        date: rec.date,
        file: pdfResult.value,
        userId: rec.userId,
        archived: rec.archived,
        updatedAt: rec.updatedAt,
      );

      final result = await _medicalRepository.addMedicalRecord(newRec);

      late final int newRecordId;
      switch (result) {
        case Ok<MedicalRecord>():
          newRecordId = result.value.id;
          debugPrint('Saved record: ${result.value}');
        case Error<MedicalRecord>():
          _errorMessage =
              "Unable to upload ${newRec.name}. Please try again.";
          debugPrint('Failed to create record: ${result.error}');
          return result;
      }

      // ── Step 3: Notify ITD via email ─────────────────────────────────────
      // Non-blocking — if email fails, the upload still succeeds.
      // ITD will receive an email with a verify link.
      final emailResult = await _medicalRepository.notifyITD(
        recordId: newRecordId,
        recordName: rec.name,
        recordDate: rec.date,
        patientName: patientName,
        patientEmail: patientEmail,
        patientIc: patientIc,
        uploadedBy: session.adminAccount.name,
      );

      switch (emailResult) {
        case Ok():
          debugPrint('ITD notification email sent.');
        case Error():
          // Log but don't fail — record is saved, email is best-effort
          debugPrint('ITD email failed (non-critical): ${emailResult.error}');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
