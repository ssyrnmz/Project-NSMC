import 'dart:io';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/medical_record.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class MedicalRecordService {
  //▫️Constructor
  MedicalRecordService({required ApiClient apiClient}) : _apiClient = apiClient;

  //▫️Variables
  final ApiClient _apiClient;
  final String _path = 'medical_record/';

  //▫️Functions:
  // Retrieve medical records
  // isAdmin=true → gets all records (verified + pending) so admin can see status
  // isAdmin=false → gets only verified records (patient view)
  Future<Result<List<MedicalRecord>>> getMedicalRecords(
    String id,
    DateTime? sync, {
    bool isAdmin = false,
  }) async {
    try {
      String fullPath = (sync != null)
          ? '${_path}get_records.php?id=$id&sync=${sync.toIso8601String()}'
          : '${_path}get_records.php?id=$id';

      // Pass role so PHP knows which filter to apply
      if (isAdmin) fullPath += '&role=admin';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final records = parsed
            .map<MedicalRecord>((json) => MedicalRecord.fromJson(json))
            .toList();

        return Result.ok(records);
      } else {
        return Result.error(
          Exception(
            'Invalid Response: ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Store a new medical record for a patient (POST)
  Future<Result<MedicalRecord>> addMedicalRecord(MedicalRecord record) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_record.php',
        body: record.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic> && body.containsKey('record_id')) {
          return Result.ok(MedicalRecord.fromJson(body));
        } else {
          final newId = int.tryParse(body.toString()) ?? 0;
          return Result.ok(MedicalRecord(
            id: newId,
            name: record.name,
            date: record.date,
            file: record.file,
            userId: record.userId,
            archived: record.archived,
            updatedAt: record.updatedAt,
          ));
        }
      } else {
        return Result.error(
          Exception(
            'Invalid Response: ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Replace a patient's medical record with updated details (POST)
  Future<Result<MedicalRecord>> editMedicalRecord(MedicalRecord record) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_record.php',
        body: record.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(record);
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Save PDF into the server first and receive path (POST)
  Future<Result<String>> savePDFToServer(File pdf) async {
    try {
      final response = await _apiClient.postFile(
        '${_path}save_file_record.php',
        item: pdf,
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        final filePath = json.decode(response.body);
        return Result.ok(filePath);
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Retrieve PDF from backend server and save it into the device (POST)
  Future<Result<File>> downloadPDF(MedicalRecord record) async {
    try {
      var map = <String, dynamic>{};
      map['id'] = record.id.toString();

      final response = await _apiClient.post(
        '${_path}download_file_record.php',
        body: map,
        auth: AuthType.required,
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        String fileName = 'medical_record.pdf';
        String? contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          final reg1 = RegExp(r'filename="(.+)"');
          final match1 = reg1.firstMatch(contentDisposition);
          if (match1 != null) {
            fileName = match1.group(1)!;
          } else {
            final reg2 = RegExp(r"filename\*\s*=\s*UTF-8''(.+)$");
            final match2 = reg2.firstMatch(contentDisposition);
            if (match2 != null) {
              fileName = Uri.decodeFull(match2.group(1)!);
            }
          }
        }

        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes, flush: true);

        return Result.ok(file);
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } catch (error) {
      return Result.error(Exception(error.toString()));
    }
  }

  // Notify ITD via email after a record is uploaded
  Future<Result<void>> notifyITD({
    required int recordId,
    required String recordName,
    required DateTime recordDate,
    required String patientName,
    required String patientEmail,
    required String patientIc,
    required String uploadedBy,
  }) async {
    try {
      final response = await _apiClient.post(
        '${_path}notify_itd.php',
        auth: AuthType.required,
        body: {
          'record_id': recordId.toString(),
          'record_name': recordName,
          'record_date':
              '${recordDate.day}/${recordDate.month}/${recordDate.year}',
          'patient_name': patientName,
          'patient_email': patientEmail,
          'patient_ic': patientIc,
          'uploaded_by': uploadedBy,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('notifyITD response: ${response.body}');
        return const Result.ok(null);
      } else {
        return Result.error(
          Exception('notify_itd failed: ${response.body}'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
