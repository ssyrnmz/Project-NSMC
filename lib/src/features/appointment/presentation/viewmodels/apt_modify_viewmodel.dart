import 'package:flutter/material.dart';

import '../../data/appointment_repository.dart';
import '../../data/notification_service.dart';
import '../../domain/appointment.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class AppointmentModifyViewModel extends ChangeNotifier {
  //▫️Constructor:
  AppointmentModifyViewModel({
    required AppointmentRepository appointmentRepository,
    required AccountSession accountSession,
    required AppointmentNotificationService notificationService,
  }) : _appointmentRepository = appointmentRepository,
       _accountSession = accountSession,
       _notificationService = notificationService;

  //▫️Variables:
  final AppointmentRepository _appointmentRepository;
  final AccountSession _accountSession;
  final AppointmentNotificationService _notificationService;

  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // Request for an appointment based on input
  Future<Result> requestAppointment(Appointment apt) async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session is! UserSession) {
      _errorMessage = "Only authenticated patients are allowed to book for appointments.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _appointmentRepository.addAppointment(apt);
      switch (result) {
        case Ok<Appointment>():
          debugPrint("Add appointment: ${result.value}");
          // Notify all admins of the new appointment request
          await _notificationService.notifyAdminNewRequest(
            appointmentId: apt.id,
            userId: session.userAccount.id,
            userEmail: session.userAccount.email,
            userName: session.userAccount.fullName,
            purpose: apt.purpose,
            appointmentDate:
                "${apt.date.day}/${apt.date.month}/${apt.date.year}",
            startTime: "${apt.startTime.hour}:${apt.startTime.minute.toString().padLeft(2, '0')}",
          );
        case Error<Appointment>():
          _errorMessage =
              "There's an issue during the appointment booking process. Please try again or at a later time.";
          debugPrint("Failed to add appointment: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update appointment's detail with updated details
  Future<Result> rescheduleAppointment(Appointment apt) async {
    final session = _accountSession.session;
    _errorMessage = null;

    if (session == null) {
      _errorMessage = "Only authenticated users are able to use this feature.";
      return Result.error(Exception(_errorMessage));
    }

    if (session is AdminSession && apt.status != "Pending") {
      _errorMessage =
          "There's an issue where the appointment is not supposed to be editted. Try again later";
      return Result.error(Exception(_errorMessage));
    }

    if (session is UserSession && apt.status != "Approved") {
      _errorMessage =
          "There's an issue where the appointment is not supposed to be editted. Try again later";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    Appointment rescheduledAppointment = Appointment(
      id: apt.id,
      purpose: apt.purpose,
      type: apt.type,
      date: apt.date,
      startTime: apt.startTime,
      endTime: apt.endTime,
      visitType: apt.visitType,
      inquiry: apt.inquiry,
      status: "Pending",
      createdAt: apt.createdAt,
      doctorId: apt.doctorId,
      userId: apt.userId,
      updatedAt: apt.updatedAt,
    );

    try {
      final result = await _appointmentRepository.editAppointment(
        rescheduledAppointment,
      );
      switch (result) {
        case Ok<Appointment>():
          debugPrint("Updated appointment: ${result.value}");
        case Error<Appointment>():
          _errorMessage =
              "There's an issue during the appointment reschedule process. Please try again or at a later time.";
          debugPrint("Failed to update appointment: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Confirm/approve an appointment
  // Pass [userEmail] and [userName] and [doctorName] from the UI layer
  // (since the viewmodel doesn't load user/doctor details directly)
  Future<Result> confirmAppointment(
    Appointment apt, {
    String userEmail = '',
    String userName = '',
    String doctorName = 'TBA',
  }) async {
    late final String statusChange;
    final session = _accountSession.session;
    _errorMessage = null;

    if (session == null) {
      _errorMessage = "Only authenticated users are able to use this feature.";
      return Result.error(Exception(_errorMessage));
    }

    if (session is AdminSession && apt.status == "Pending") {
      statusChange = "Approved";
    } else if (session is UserSession && apt.status == "Approved") {
      statusChange = "Confirmed";
    } else {
      _errorMessage =
          "There's an issue where the appointment has been wrongly approved by the system. Try again later";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    Appointment confirmedAppointment = Appointment(
      id: apt.id,
      purpose: apt.purpose,
      type: apt.type,
      date: apt.date,
      startTime: apt.startTime,
      endTime: apt.endTime,
      visitType: apt.visitType,
      inquiry: apt.inquiry,
      status: statusChange,
      createdAt: apt.createdAt,
      doctorId: apt.doctorId,
      userId: apt.userId,
      updatedAt: apt.updatedAt,
    );

    try {
      final result = await _appointmentRepository.editAppointment(
        confirmedAppointment,
      );
      switch (result) {
        case Ok<Appointment>():
          debugPrint("Confirmed/Approved appointment: \${result.value} $statusChange");
          // Admin approves → notify patient via in-app + email
          if (session is AdminSession && statusChange == "Approved") {
            await _notificationService.notifyUserApproved(
              appointmentId: apt.id,
              userId: apt.userId,
              userEmail: userEmail,
              userName: userName,
              purpose: apt.purpose,
              appointmentDate:
                  "\${apt.date.day}/\${apt.date.month}/\${apt.date.year}",
              startTime: "\${apt.startTime.hour}:\${apt.startTime.minute.toString().padLeft(2, '0')}",
              endTime: "\${apt.endTime.hour}:\${apt.endTime.minute.toString().padLeft(2, '0')}",
              doctorName: doctorName,
            );
          }
          // Patient confirms → notify admin via in-app
          if (session is UserSession && statusChange == "Confirmed") {
            await _notificationService.notifyAdminConfirmed(
              appointmentId: apt.id,
              userId: apt.userId,
              userName: userName,
              purpose: apt.purpose,
              appointmentDate:
                  "\${apt.date.day}/\${apt.date.month}/\${apt.date.year}",
            );
          }
        case Error<Appointment>():
          _errorMessage =
              "There's an issue when approving your appointment. Try again later.";
          debugPrint("Failed to confirm appointment: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}