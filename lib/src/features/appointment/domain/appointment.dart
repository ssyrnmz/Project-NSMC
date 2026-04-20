import 'package:flutter/material.dart';

class Appointment {
  //▫️Variables
  final int id;
  final String purpose;
  final String type;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String visitType;
  final String? inquiry;
  final String status;
  final DateTime createdAt;
  final int? doctorId;
  final String userId;
  final DateTime updatedAt;

  //▫️Constructor
  Appointment({
    required this.id,
    required this.purpose,
    required this.type,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.visitType,
    required this.inquiry,
    required this.status,
    required this.createdAt,
    required this.doctorId,
    required this.userId,
    required this.updatedAt,
  });

  //▫️Converter functions
  // Convert json data into doctor class when retrieved
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: int.parse(json['appointment_id'].toString()),
      purpose: json['appointment_purpose'] as String,
      type: json['appointment_type'] as String,
      date: DateTime.parse(json['appointment_date']),
      startTime: TimeOfDay.fromDateTime(
        DateTime.parse('0000-00-00 ${json['appointment_start_time']}'),
      ),
      endTime: TimeOfDay.fromDateTime(
        DateTime.parse('0000-00-00 ${json['appointment_end_time']}'),
      ),
      visitType: json['appointment_visit_type'] as String,
      inquiry: json['appointment_inquiry'] as String?,
      status: json['appointment_status'] as String,
      createdAt: DateTime.parse(json['appointment_created_at']),
      doctorId: json['doctor_id'] != null
          ? int.parse(json['doctor_id'].toString())
          : null,
      userId: json['user_id'] as String,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert doctor data into json format for sending
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'purpose': purpose,
      'type': type,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'visitType': visitType,
      'inquiry': inquiry,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'doctorId': doctorId != null ? doctorId.toString() : '',
      'userId': userId,
    };
  }
}