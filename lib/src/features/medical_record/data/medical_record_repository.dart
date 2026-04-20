import 'dart:io';

import 'medical_record_service.dart';
import '../domain/medical_record.dart';
import '../../../utils/data/results.dart';

class MedicalRecordRepository {
  //▫️Constructor:
  MedicalRecordRepository({required MedicalRecordService medicalRecordService})
    : _medicalRecordService = medicalRecordService;

  //▫️Variables:
  final MedicalRecordService _medicalRecordService;
  DateTime? _lastSync;
  List<MedicalRecord> _cache = [];
  String? _cacheOwner;

  //▫️Functions:
  // Get medical records
  // isAdmin=true → all records (admin can see pending + verified)
  // isAdmin=false → only verified records (patient view)
  Future<Result<List<MedicalRecord>>> getMedicalRecords(
    String id, {
    bool isAdmin = false,
  }) async {
    if (_cacheOwner != id) {
      _cache = [];
      _lastSync = null;
      _cacheOwner = id;
    }
    final result = await _medicalRecordService.getMedicalRecords(
      id,
      _lastSync,
      isAdmin: isAdmin,
    );

    switch (result) {
      case Ok<List<MedicalRecord>>():
        final records = result.value;

        if (records.isNotEmpty) {
          _updateCache(records);
          _lastSync = records.first.updatedAt;
        }

        return Result.ok(_cache);
      case Error<List<MedicalRecord>>():
        return Result.error(result.error);
    }
  }

  // Add a new record
  Future<Result<MedicalRecord>> addMedicalRecord(MedicalRecord record) async {
    final result = await _medicalRecordService.addMedicalRecord(record);
    return result;
  }

  // Update a record's information or archive it
  Future<Result<MedicalRecord>> editMedicalRecord(MedicalRecord record) async {
    final result = await _medicalRecordService.editMedicalRecord(record);

    if (result is Ok<MedicalRecord>) {
      if (record.archived) {
        _cache.removeWhere((rec) => rec.id == record.id);
        _lastSync = result.value.updatedAt;
      }
    }

    return result;
  }

  // Save the PDF file of medical record
  Future<Result<String>> uploadFile(File pdf) async {
    return await _medicalRecordService.savePDFToServer(pdf);
  }

  // Download and open medical record PDF file
  Future<Result<File>> downloadPDF(MedicalRecord record) async {
    return await _medicalRecordService.downloadPDF(record);
  }

  // Notify ITD via email after upload
  Future<Result<void>> notifyITD({
    required int recordId,
    required String recordName,
    required DateTime recordDate,
    required String patientName,
    required String patientEmail,
    required String patientIc,
    required String uploadedBy,
  }) async {
    return await _medicalRecordService.notifyITD(
      recordId: recordId,
      recordName: recordName,
      recordDate: recordDate,
      patientName: patientName,
      patientEmail: patientEmail,
      patientIc: patientIc,
      uploadedBy: uploadedBy,
    );
  }

  //▫️Helpers:
  void _updateCache(List<MedicalRecord> records) {
    if (_cache.isNotEmpty) {
      for (final data in records) {
        final index = _cache.indexWhere((rec) => rec.id == data.id);
        if (index != -1) {
          _cache[index] = data;
        } else {
          _cache.add(data);
        }
      }
    } else {
      _cache = List.from(records);
    }
  }
}
