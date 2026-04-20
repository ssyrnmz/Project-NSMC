import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';

/// Calls backend PHP endpoints to trigger notifications
/// for appointment events. Failures are non-critical — logged and swallowed
/// so the app flow is never blocked by a notification failure.
class AppointmentNotificationService {
  AppointmentNotificationService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  final String _path = 'appointment/';

  /// Called when a USER books a new appointment.
  /// Sends in-app + email notification to all admins.
  Future<void> notifyAdminNewRequest({
    required int appointmentId,
    required String userId,
    required String userEmail,
    required String userName,
    required String purpose,
    required String appointmentDate,
    required String startTime,
  }) async {
    try {
      await _apiClient.post(
        '${_path}notify_admin_new_request.php',
        body: {
          'appointment_id': appointmentId.toString(),
          'user_id': userId,
          'user_email': userEmail,
          'user_name': userName,
          'purpose': purpose,
          'date': appointmentDate,
          'start_time': startTime,
        },
        auth: AuthType.required,
      );
      debugPrint('[Notification] Admin notified of new request #$appointmentId');
    } catch (e) {
      debugPrint('[Notification] Admin notify failed (non-critical): $e');
    }
  }

  /// Called when an ADMIN approves an appointment (status → "Approved").
  /// Sends in-app + email notification to the patient.
  Future<void> notifyUserApproved({
    required int appointmentId,
    required String userId,
    required String userEmail,
    required String userName,
    required String purpose,
    required String appointmentDate,
    required String startTime,
    required String endTime,
    required String doctorName,
  }) async {
    try {
      await _apiClient.post(
        '${_path}notify_user_approved.php',
        body: {
          'appointment_id': appointmentId.toString(),
          'user_id': userId,
          'user_email': userEmail,
          'user_name': userName,
          'purpose': purpose,
          'date': appointmentDate,
          'start_time': startTime,
          'end_time': endTime,
          'doctor_name': doctorName,
        },
        auth: AuthType.required,
      );
      debugPrint('[Notification] User $userEmail notified of approval #$appointmentId');
    } catch (e) {
      debugPrint('[Notification] User approved notify failed (non-critical): $e');
    }
  }

  /// Called when a PATIENT confirms their appointment (status → "Confirmed").
  /// Sends in-app + email notification to all admins.
  Future<void> notifyAdminConfirmed({
    required int appointmentId,
    required String userId,
    required String userName,
    required String purpose,
    required String appointmentDate,
  }) async {
    try {
      await _apiClient.post(
        '${_path}notify_admin_user_confirmed.php',
        body: {
          'appointment_id': appointmentId.toString(),
          'user_id': userId,
          'user_name': userName,
          'purpose': purpose,
          'date': appointmentDate,
        },
        auth: AuthType.required,
      );
      debugPrint('[Notification] Admin notified of confirmation #$appointmentId');
    } catch (e) {
      debugPrint('[Notification] Admin confirmed notify failed (non-critical): $e');
    }
  }
}
