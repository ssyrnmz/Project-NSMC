// Info: Repository for caching prescription data and error handling.
import 'dart:io';
import 'prescription_service.dart';
import '../domain/prescription.dart';
import '../../../utils/data/results.dart';

class PrescriptionRepository {
  //▫️Constructor
  PrescriptionRepository({required PrescriptionService prescriptionService})
      : _prescriptionService = prescriptionService;

  //▫️Variables
  final PrescriptionService _prescriptionService;
  DateTime? _lastSync;
  List<Prescription> _cache = [];
  String? _cacheOwner; // tracks whose data is cached ('admin' or userId)

  //▫️Functions:

  // Get all prescriptions for a user
  Future<Result<List<Prescription>>> getPrescriptions(String id) async {
    if (_cacheOwner != id) {
      clearCache();
      _cacheOwner = id;
    }
    final result = await _prescriptionService.getPrescriptions(id, _lastSync);

    switch (result) {
      case Ok<List<Prescription>>():
        final prescriptions = result.value;
        if (prescriptions.isNotEmpty) {
          _updateCache(prescriptions);
          _lastSync = prescriptions.first.updatedAt;
        }
        return Result.ok(_cache);
      case Error<List<Prescription>>():
        return Result.error(result.error);
    }
  }

  // Get all prescriptions (admin)
  Future<Result<List<Prescription>>> getAllPrescriptions() async {
    if (_cacheOwner != 'admin') {
      clearCache();
      _cacheOwner = 'admin';
    }
    final result = await _prescriptionService.getAllPrescriptions(_lastSync);

    switch (result) {
      case Ok<List<Prescription>>():
        final prescriptions = result.value;
        if (prescriptions.isNotEmpty) {
          _updateCache(prescriptions);
          _lastSync = prescriptions.first.updatedAt;
        }
        return Result.ok(_cache);
      case Error<List<Prescription>>():
        return Result.error(result.error);
    }
  }

  // Add a new prescription
  Future<Result<Prescription>> addPrescription(
      Prescription prescription) async {
    final result = await _prescriptionService.addPrescription(prescription);
    if (result is Ok<Prescription>) {
      _cache.add(result.value);
      _lastSync = result.value.updatedAt;
    }
    return result;
  }

  // Update an existing prescription
  Future<Result<Prescription>> editPrescription(
      Prescription prescription) async {
    final result = await _prescriptionService.editPrescription(prescription);
    if (result is Ok<Prescription>) {
      final idx = _cache.indexWhere((p) => p.id == prescription.id);
      if (idx != -1) _cache[idx] = result.value;
    }
    return result;
  }

  // Delete a prescription
  Future<Result<void>> deletePrescription(int id) async {
    final result = await _prescriptionService.deletePrescription(id);
    if (result is Ok<void>) {
      _cache.removeWhere((p) => p.id == id);
    }
    return result;
  }

  // NEW: Upload PDF file to server; returns the stored filename
  Future<Result<String>> uploadPDF(File pdf) async {
    return await _prescriptionService.savePDFToServer(pdf);
  }

  // NEW: Build a secure signed URL for inline PDF viewing (no download)
  String buildViewUrl(int prescriptionId) {
    return _prescriptionService.buildViewUrl(prescriptionId);
  }

  //▫️Cache helpers
  void _updateCache(List<Prescription> incoming) {
    for (final p in incoming) {
      final idx = _cache.indexWhere((c) => c.id == p.id);
      if (idx == -1) {
        _cache.add(p);
      } else {
        _cache[idx] = p;
      }
    }
  }

  void clearCache() {
    _cache = [];
    _lastSync = null;
  }
}
