import 'package:flutter/material.dart';

//▫️Enumerations (Categories)
// User Profile Details

// Change the enum values for only display later if necessary
enum Nationality {
  malaysian("Malaysian"),
  nonMalaysian("Non Malaysian");

  final String value;
  const Nationality(this.value);
}

enum Gender {
  male("Male"),
  female("Female");

  final String value;
  const Gender(this.value);
}

// Appointment Details
enum AppointmentType {
  newly("New Appointment"),
  rescheduled("Reschedule");

  final String value;
  const AppointmentType(this.value);
}

enum AppointmentVisitType {
  newly("New Visit"),
  followUp("Follow Up Visit");

  final String value;
  const AppointmentVisitType(this.value);
}

// Doctor Details
enum DoctorStatus {
  // enum value (String value [for display and storing])
  resident("Resident"),
  visiting("Visiting");

  final String value;
  const DoctorStatus(this.value);
}

// Screen Modes
enum ScreenRole { view, history, add, edit, delete }

enum UserRole { all, user, admin }

//▫️Lists
// Appointment Options
final Map<String, Map<String, TimeOfDay>> timeOptions = {
  // <time display name <start/end, time>>
  'Between 8.30 am - 13.00 pm': {
    'start': TimeOfDay(hour: 8, minute: 30),
    'end': TimeOfDay(hour: 13, minute: 00),
  },
  'Between 2.00 pm - 4.00 pm': {
    'start': TimeOfDay(hour: 14, minute: 00),
    'end': TimeOfDay(hour: 16, minute: 00),
  },
};

final Map<String, Map<String, TimeOfDay>> timeSaturdayOptions = {
  // <time display name <start/end, time>>
  'Between 8.30 am - 13.00 pm': {
    'start': TimeOfDay(hour: 8, minute: 30),
    'end': TimeOfDay(hour: 13, minute: 00),
  },
};

const Map<String, int> appointmentPurposeOptions = {
  // <purpose, speciality ID>
  "Anaesthesiologist & Critical Care": 1,
  "Cardiac Catheterization Procedure": 2,
  "Cardiothoracic Surgery": 2,
  "Circumcision": 6,
  "College / Pre-U Health Screening": 11,
  "Ct Calcium Score Screening": 9,
  "Biopsy And Report": 4,
  "Composite Veneer": 4,
  "Crown And Bridges": 4,
  "Dental Implants": 4,
  "Dentures": 4,
  "Extraction": 4,
  "Filing": 4,
  "Fluoride Varnish (Paediatric)": 4,
  "Root Canal Treatment": 4,
  "Scaling, Polishing": 4,
  "Teeth Whitening": 4,
  "Third Molar Surgery": 4,
  "Xray-Periapical, Panoramic, Lateral Cephalometric": 4,
  "Diabetic Care": 10,
  "Foreign Work Permit Medical Check Up": 11,
  "General & Colorectal Surgery": 6,
  "General & Hepatobiliary Surgery": 6,
  "Health Screening Package-Superior": 8,
  "Health Screening Package-Senior Exec": 8,
  "Health Screening Package-Essential": 8,
  "Health Screening Package-Essential Plus": 8,
  "General Surgery": 6,
  "General Treatment": 0,
  "Haematology": 7,
  "Heart Risk Screening (Regular)": 11,
  "Inoculation / Injection for Immunity (Adult)": 3,
  "Inoculation / Injection for Immunity (Newborn to Child)": 3,
  "Injection For Typhoid": 6,
  "Internal Medicine": 8,
  "Internal Medicine / Cardiology": 9,
  "Internal Medicine / Dermatology": 8,
  "Internal Medicine / Nephrology": 10,
  "Ird 40 Years Old and Above": 0,
  "Ird Below 40 Years Old": 0,
  "Laser Haemorrhoid": 26,
  "Liver Elastography": 24,
  "Malaysia Day Check Up Package": 11,
  "Malaysia My 2nd Home (MM2H) Health Screening": 11,
  "Maxillofacial Surgery": 18,
  "Medical Surveillance": 1,
  "Men Elite Health Screening Package": 11,
  "Men's Health": 26,
  "MSCT Virtual Colonography": 16,
  "Nutrition Service": 0,
  "Neuroanaesthesia & Neurointensive Care": 12,
  "Neurology": 13,
  "Neurosurgery": 14,
  "Obstetrics & Gynaecology": 15,
  "Occupational Health": 1,
  "Offshore Medical Check-Up for Petronas Staff with Lou Under AIA": 11,
  "Ophthalmology": 17,
  "Oncology": 16,
  "Oral Surgery": 18,
  "Oral Maxillofacial Surgery": 18,
  "Orthopaedic Surgery": 19,
  "Otorhinolaryngology (Ent)": 20,
  "Paediatrics": 21,
  "Pilgrimage Screening (Haji/Umrah)": 11,
  "Plastic Surgery": 22,
  "Post Covid-19 Screening": 11,
  "Pre-Employment Health Screening": 11,
  "Psychiatry": 23,
  "Rheumatology": 19,
  "Stroke Risk Screening": 8,
  "Urology": 26,
  "Medical Check-Up UK": 11,
  "Medical Check-Up NZ": 11,
  "Medical Check-Up Australia": 11,
  "Women Wellness : 40 Years Old & Below": 15,
  "Women Premier : Above 40 Years Old": 15,
  "Wound Care": 6,
};

// Public holidays are now managed via the database (PublicHolidayRepository).
// Admins can add/remove holidays from the Holiday Management screen.
// See: lib/src/features/appointment/domain/public_holiday.dart

// Emergency Contact Options
const List<String> relationships = [
  'Father',
  'Mother',
  'Brother',
  'Sister',
  'Spouse',
  'Friend',
  'Other',
];

//▫️Image List
// Speciality images
const Map<int, String> specialityImageBoxes = {
  // <speciality ID, image file name>
  1: 'assets/svg/11a.svg',
  2: 'assets/svg/11c.svg',
  3: 'assets/svg/11m.svg',
  4: 'assets/svg/11d.svg',
  5: 'assets/svg/11e.svg',
  6: 'assets/svg/11g.svg',
  7: 'assets/svg/11h.svg',
  8: 'assets/svg/11i.svg',
  9: 'assets/svg/11ca.svg',
  10: 'assets/svg/dermatology.svg',
  11: 'assets/svg/medof.svg',
  12: 'assets/svg/neuroanas.svg',
  13: 'assets/svg/neulo.svg',
  14: 'assets/svg/neusur.svg',
  15: 'assets/svg/ong.svg',
  16: 'assets/svg/onco.svg',
  17: 'assets/svg/ophth.svg',
  18: 'assets/svg/omax.svg',
  19: 'assets/svg/ortho.svg',
  20: 'assets/svg/otorhino.svg',
  21: 'assets/svg/paed.svg',
  22: 'assets/svg/plas.svg',
  23: 'assets/svg/psy.svg',
  24: 'assets/svg/rad.svg',
  25: 'assets/svg/rehab.svg',
  26: 'assets/svg/uro.svg',
};