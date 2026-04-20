// Info: Handles data transfer between the app and backend for prescriptions.
import 'dart:convert';
import 'dart:io';

import '../domain/prescription.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';
import '../../../config/constants/api_url.dart';

class PrescriptionService {
  //▫️Constructor
  PrescriptionService({required ApiClient apiClient})
      : _apiClient = apiClient;

  //▫️Variables
  final ApiClient _apiClient;
  final String _path = 'prescription/';

  //▫️Functions:

  // Retrieve all prescriptions of a user (GET)
  Future<Result<List<Prescription>>> getPrescriptions(
    String id,
    DateTime? sync,
  ) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_prescriptions.php?id=$id&sync=${sync.toIso8601String()}'
          : '${_path}get_prescriptions.php?id=$id';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final prescriptions =
            parsed.map<Prescription>((j) => Prescription.fromJson(j)).toList();
        return Result.ok(prescriptions);
      } else {
        return Result.error(
          Exception(
              'Invalid Response: ${response.body} (${response.statusCode})'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Retrieve all prescriptions for all users (admin) (GET)
  Future<Result<List<Prescription>>> getAllPrescriptions(DateTime? sync) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_all_prescriptions.php?sync=${sync.toIso8601String()}'
          : '${_path}get_all_prescriptions.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final prescriptions =
            parsed.map<Prescription>((j) => Prescription.fromJson(j)).toList();
        return Result.ok(prescriptions);
      } else {
        return Result.error(
          Exception(
              'Invalid Response: ${response.body} (${response.statusCode})'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Store a new prescription (admin POST)
  Future<Result<Prescription>> addPrescription(
      Prescription prescription) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_prescription.php',
        body: prescription.toJson(),
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return Result.ok(Prescription.fromJson(body));
      } else {
        return Result.error(
          Exception(
              'Invalid Response: ${response.body} (${response.statusCode})'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Update an existing prescription (admin POST)
  Future<Result<Prescription>> editPrescription(
      Prescription prescription) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_prescription.php',
        body: prescription.toJson(),
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        return Result.ok(prescription);
      } else {
        return Result.error(
          Exception(
              'Invalid Response: ${response.body} (${response.statusCode})'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Delete/archive a prescription (admin POST)
  Future<Result<void>> deletePrescription(int id) async {
    try {
      final response = await _apiClient.post(
        '${_path}delete_prescription.php',
        body: {'id': id.toString()},
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        return const Result.ok(null);
      } else {
        return Result.error(
          Exception(
              'Invalid Response: ${response.body} (${response.statusCode})'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // NEW: Upload a PDF file for a prescription (multipart POST)
  Future<Result<String>> savePDFToServer(File pdf) async {
    try {
      final response = await _apiClient.postFile(
        '${_path}save_file_prescription.php',
        item: pdf,
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        final filename = json.decode(response.body) as String;
        return Result.ok(filename);
      } else {
        return Result.error(
          Exception(
              'Upload failed: ${response.body} (${response.statusCode})'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // NEW: Build a signed URL for inline viewing of a prescription PDF.
  //
  // Uses only dart:convert (no extra packages).
  // Token = base64Url( prescriptionId + ':' + secret )
  //
  // view_prescription.php validates this token. Because the patient
  // must also pass Firebase auth (validateUser()), the token is a
  // secondary check — the Firebase token is the primary security layer.
  String buildViewUrl(int prescriptionId) {
    const secret = 'nmsc_presc_view_secret_2026'; // keep in sync with PHP
    final raw    = '$prescriptionId:$secret';
    final token  = base64Url.encode(utf8.encode(raw));
    return '${ConfigAPI.baseUrl}prescription/view_prescription.php'
        '?id=$prescriptionId&token=${Uri.encodeComponent(token)}';
  }
}
