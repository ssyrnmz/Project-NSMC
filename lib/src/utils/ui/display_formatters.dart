import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisplayFormat {
  //❕Shared formatter to display any sort of data

  //▫️Format Functions:
  // DATE:
  // Display Date (1 Jan 2025)
  String date(DateTime value) {
    return DateFormat('dd MMM yyyy').format(value);
  }

  // Display Date (01/01/2025)
  String dateSlash(DateTime value) {
    return DateFormat('dd/MM/y').format(value);
  }

  // TIME:
  // Display Start and End Time together (HH:MM M - HH:MM M)
  String timeRange(TimeOfDay startValue, TimeOfDay endValue) {
    return '${startValue.hour.toString().padLeft(2, '0')}:${startValue.minute.toString().padLeft(2, '0')} ${startValue.period.name.toUpperCase()} - ${endValue.hour.toString().padLeft(2, '0')}:${endValue.minute.toString().padLeft(2, '0')} ${endValue.period.name.toUpperCase()}';
  }

  // Display Time (HH:MM)
  String timeOnly(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // SHORT PATIENT NAME:
  // Display Patient's name in shorter length
  String shortUserName(String name) {
    if (name.length >= 20) {
      name = name.replaceRange(17, null, "...");
    }

    return name;
  }

  // SHORT DOCTOR NAME:
  // Display Doctor's name in shorter length
  String shortDoctorName(String name) {
    List<String> splitName = name.split(' ');
    String? convertedName;

    for (int i = 0; i < splitName.length; i++) {
      if (splitName[i] == 'DR.' || splitName[i] == 'Dr.') {
        convertedName = '${splitName[i]}  ${splitName[i + 1]}';
      }
    }
    return convertedName ?? name;
  }

  // HEALTH PACKAGE NAME
  String packageName(String name, String? code) {
    return (code != null) ? "$name ($code)" : name;
  }

  // PDF RECORD NAME:
  // Display Medical Record's file name with (PDF) at the end
  String medicalRecordName(String name) {
    return '$name (PDF)';
  }

  // INFO MESSAGE
  String infoMessage(String desc) {
    return (desc.length >= 20) ? desc.replaceRange(17, null, "...") : desc;
  }
}
