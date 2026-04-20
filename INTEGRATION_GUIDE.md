# NMSC App — Prescription Feature & Outstanding Items Guide

---

## PART 1 — HOW TO INTEGRATE THE PRESCRIPTION FEATURE

### Step 1 — Copy Flutter files into your lib folder

Copy the entire `lib/` folder structure from this deliverable into your
existing Flutter project's `lib/` folder. The new feature lives at:

  lib/src/features/prescription/
  ├── domain/
  │   └── prescription.dart              ← Prescription & Medication models
  ├── data/
  │   ├── prescription_service.dart      ← API calls
  │   └── prescription_repository.dart  ← Cache + error handling
  └── presentation/
      ├── viewmodels/
      │   ├── presc_view_viewmodel.dart   ← Load, search, filter
      │   └── presc_modify_viewmodel.dart ← Add, edit, delete (admin)
      └── views/
          ├── presc_management_screen.dart        ← User list (Current/History)
          ├── presc_details_screen.dart           ← Full prescription view
          ├── presc_modify_screen.dart            ← Admin add/edit form
          ├── patient_presc_overview_screen.dart  ← Admin patient overview
          └── widgets/
              └── presc_management_box.dart       ← List item card


### Step 2 — Register providers in provider_dependencies.dart

Open lib/src/config/provider_dependencies.dart and:

a) Add imports at the top:
   import '../features/prescription/data/prescription_service.dart';
   import '../features/prescription/data/prescription_repository.dart';
   import '../features/prescription/presentation/viewmodels/presc_view_viewmodel.dart';
   import '../features/prescription/presentation/viewmodels/presc_modify_viewmodel.dart';

b) Add inside mainProviders list (after MedicalRecord entries):
   // Services
   Provider(create: (context) => PrescriptionService(apiClient: context.read())),
   // Repositories
   Provider(create: (context) => PrescriptionRepository(prescriptionService: context.read())),
   // ViewModels
   ChangeNotifierProvider(create: (context) => PrescriptionViewModel(
     prescriptionRepository: context.read(), accountSession: context.read())),
   ChangeNotifierProvider(create: (context) => PrescriptionModifyViewModel(
     prescriptionRepository: context.read(), accountSession: context.read())),


### Step 3 — Add navigation to the prescription screens

To navigate to the user prescription screen (from home/profile):
   Navigator.push(context, transitionAnimation(
     page: const PrescManagementScreen()));

To navigate to the admin patient prescription overview:
   Navigator.push(context, transitionAnimation(
     page: PatientPrescOverviewScreen(
       userId: patient.id,
       patientName: patient.name)));


### Step 4 — Set up the database

Run DATABASE_SCHEMA.sql on your XAMPP MySQL server (nmsc_app database).
This creates the `prescriptions` and `prescription_medications` tables.


### Step 5 — Upload backend PHP files

Copy the 3 PHP files from backend/ to:
  C:\xampp\htdocs\nmsc_app\prescription\

  ├── get_prescriptions.php
  ├── add_prescription.php
  ├── update_prescription.php
  └── delete_prescription.php

These follow the exact same structure as your existing appointment/ and
medical_record/ PHP files.


### Step 6 — Verify SVG asset

The PrescManagementBox widget uses:
  assets/svgs/medBlueT.svg

Check that this file exists in your assets folder. If the name is
different, update the path in presc_management_box.dart line ~43.


---

## PART 2 — OTHER OUTSTANDING ITEMS (How to fix)

---

### FIX 1 — Appointment Reschedule Screen (apt_reschedule_screen.dart)

Problem: Input fields don't follow the same rules as the booking screen
(doctor filtered by purpose, no Sundays/holidays, time constraints).

Fix — in apt_reschedule_screen.dart, apply these same validators that
exist in apt_booking_screen.dart:

1. Doctor dropdown — filter doctors by appointment purpose:
   Filter the doctors list using the appointment's existing `purpose`
   field. Reuse the same logic from the booking screen's doctor selector.

2. Date picker — block Sundays and public holidays:
   In the showRoundedDatePicker call, add a selectableDayPredicate:

   selectableDayPredicate: (date) {
     final isSunday = date.weekday == DateTime.sunday;
     final isHoliday = GlobalValues.publicHolidays.contains(
       DateTime(date.year, date.month, date.day));
     return !isSunday && !isHoliday;
   },

   Where GlobalValues.publicHolidays is a List<DateTime> you populate
   via the Calendar Business Logic (see Fix 5 below).

3. Time picker — restrict to allowed slots:
   Reuse the same allowed time range constants from apt_booking_screen.dart.
   Apply the same NumberPicker min/max/step values for hour and minute.


### FIX 2 — Appointment Backend Logic (null doctor bug)

Problem: Appointment cannot be saved when "Any Doctor" (null) is selected.

File: lib/src/features/appointment/data/appointment_service.dart

In the addAppointment / editAppointment method, the toJson() call on
Appointment sends `doctorId: null.toString()` which becomes the string
"null" — causing a backend parse error.

Fix in Appointment.toJson():
  // BEFORE (broken):
  'doctorId': doctorId.toString(),

  // AFTER (fixed):
  'doctorId': doctorId != null ? doctorId.toString() : '',

Then in your PHP add_appointment.php:
  $doctor_id = (!empty($data['doctorId'])) ? intval($data['doctorId']) : NULL;
  // Use NULL in the SQL INSERT so the column accepts it properly.


### FIX 3 — Terms & Conditions Screen

File: lib/src/features/authentication/presentation/views/terms_conditions_screen.dart

Option A (Recommended — link to Normah's website):
  Replace the body content with a WebView that loads the URL:

  dependencies to add in pubspec.yaml:
    webview_flutter: ^4.4.2

  Widget:
    WebViewWidget(controller: WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.normah.com.my/terms')))

Option B (Embed content):
  Copy the text from Normah's website into the screen as a
  SingleChildScrollView with Text paragraphs.


### FIX 4 — Account Registration Screen

File: lib/src/features/authentication/presentation/views/register_screen.dart

a) IC Type dropdown — add before the IC number field:
   DropdownButtonFormField<String>(
     value: _icType,
     items: const [
       DropdownMenuItem(value: 'MyKad',      child: Text('MyKad')),
       DropdownMenuItem(value: 'MyTentera',  child: Text('MyTentera')),
     ],
     onChanged: (val) => setState(() => _icType = val!),
     decoration: InputDecoration(labelText: 'IC Type'),
   )

b) Password requirement box — add a StatefulWidget below the password field
   that listens to the password controller and shows 4 colored ticks/crosses:
   - More than 8 characters (max 64)
   - At least 1 uppercase letter
   - At least 1 lowercase letter
   - At least 1 number
   - At least 1 special character

   Use a ValueListenableBuilder on the password TextEditingController:
   ValueListenableBuilder<TextEditingValue>(
     valueListenable: _passwordCtrl,
     builder: (context, value, _) {
       final pwd = value.text;
       return Column(children: [
         _reqRow('8–64 characters',          pwd.length >= 8 && pwd.length <= 64),
         _reqRow('Uppercase letter',         pwd.contains(RegExp(r'[A-Z]'))),
         _reqRow('Lowercase letter',         pwd.contains(RegExp(r'[a-z]'))),
         _reqRow('Number',                   pwd.contains(RegExp(r'[0-9]'))),
         _reqRow('Special character',        pwd.contains(RegExp(r'[!@#\$%^&*]'))),
       ]);
     },
   )

   Helper:
   Widget _reqRow(String label, bool met) => Row(children: [
     Icon(met ? Icons.check_circle : Icons.cancel,
          color: met ? Colors.green : Colors.red, size: 16),
     const SizedBox(width: 6),
     Text(label, style: TextStyle(color: met ? Colors.green : Colors.red, fontSize: 12)),
   ]);


### FIX 5 — Calendar Business Logic (Admin holiday management)

This requires a new feature. The quickest approach:

a) Add a `public_holidays` table to MySQL:
   CREATE TABLE public_holidays (
     holiday_id   INT AUTO_INCREMENT PRIMARY KEY,
     holiday_date DATE NOT NULL,
     holiday_name VARCHAR(255) NOT NULL
   );

b) Create PHP endpoints:
   - get_holidays.php  → returns all holiday dates
   - add_holiday.php   → admin adds a holiday
   - delete_holiday.php → admin removes a holiday

c) In Flutter, load holidays at app start (in HomeViewModel or
   GlobalValues) and store as a List<DateTime> for use in date pickers.

d) Add an admin UI screen (similar to doctor_modify_screen.dart) where
   admins can add/remove public holidays from a calendar.


### FIX 6 — Package Filter Screen (health_screening category)

File: lib/src/features/health_screening/domain/health_screening.dart

a) Add a `category` field to the HealthScreening model:
   final String? category;  // e.g. "General", "Special Programme", "Specialized"

b) In HealthScreening.fromJson():
   category: json['screening_category'] as String?,

c) In the MySQL health_screening table, add:
   ALTER TABLE health_screening ADD COLUMN screening_category VARCHAR(100) DEFAULT NULL;

d) In filter_hsp.dart, populate the category filter chips from the
   unique categories in the loaded HealthScreening list, then filter
   in HealthScreeningViewModel when a chip is selected.


### FIX 7 — Admin Role Levels

a) In MySQL accounts/admins table, add:
   ALTER TABLE admins ADD COLUMN admin_role ENUM('superadmin','admin','staff') DEFAULT 'admin';

b) In Admin domain model (domain/admin.dart), add:
   final String role;
   // parse from json: role: json['admin_role'] as String

c) In AccountSession, expose:
   bool get isSuperAdmin => session is AdminSession && session.adminAccount.role == 'superadmin';

d) Use isSuperAdmin to gate sensitive features like deleting prescriptions,
   managing other admins, etc.


---

## PART 3 — QUICK CHECKLIST

  [x] Prescription domain model
  [x] Prescription service (API calls)
  [x] Prescription repository (caching)
  [x] PrescriptionViewModel (view/search)
  [x] PrescriptionModifyViewModel (add/edit/delete)
  [x] PrescManagementBox widget
  [x] PrescDetailsScreen
  [x] PrescManagementScreen (user)
  [x] PrescModifyScreen (admin add/edit)
  [x] PatientPrescOverviewScreen (admin)
  [x] Provider dependencies additions
  [x] Database SQL schema
  [x] PHP backend (get/add/update/delete)

  [ ] Appointment reschedule fixes (see Fix 1 & 2 above)
  [ ] Terms & Conditions screen (see Fix 3 above)
  [ ] Registration IC type + password box (see Fix 4 above)
  [ ] Calendar/holiday admin feature (see Fix 5 above)
  [ ] Package filter category (see Fix 6 above)
  [ ] Admin role levels (see Fix 7 above)
