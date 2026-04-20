import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/api/api_client.dart';
import '../features/authentication/data/client_services/firebase_auth_repository.dart';

import '../features/authentication/data/account_session.dart';
import '../features/appointment/data/appointment_service.dart';
import '../features/appointment/data/notification_service.dart' as apt_notif;
import '../features/appointment/data/public_holiday_service.dart';
import '../features/authentication/data/client_services/admin_service.dart';
import '../features/authentication/data/client_services/user_service.dart';
import '../features/doctor/data/doctor_service.dart';
import '../features/doctor/data/speciality_service.dart';
import '../features/health_screening/data/health_screening_service.dart';
import '../features/health_screening/data/carousel_poster_service.dart';
import '../features/medical_record/data/medical_record_service.dart';
import '../features/notification/data/notification_service.dart';
import '../features/profile/data/emergency_contact_service.dart';

import '../features/authentication/data/repositories/user_repository.dart';
import '../features/appointment/data/appointment_repository.dart';
import '../features/appointment/data/public_holiday_repository.dart';
import '../features/doctor/data/doctor_repository.dart';
import '../features/doctor/data/speciality_repository.dart';
import '../features/health_screening/data/health_screening_repository.dart';
import '../features/health_screening/data/carousel_poster_repository.dart';
import '../features/medical_record/data/medical_record_repository.dart';
import '../features/notification/data/notification_repository.dart';

import '../features/appointment/presentation/viewmodels/apt_modify_viewmodel.dart';
import '../features/appointment/presentation/viewmodels/apt_view_viewmodel.dart';
import '../features/authentication/presentation/viewmodels/auth_account_viewmodel.dart';
import '../features/authentication/presentation/viewmodels/auth_verify_viewmodel.dart';
import '../features/doctor/presentation/viewmodels/doctor_modify_viewmodel.dart';
import '../features/doctor/presentation/viewmodels/doctor_view_viewmodel.dart';
import '../features/health_screening/presentation/viewmodels/carousel_edit_viewmodel.dart';
import '../features/health_screening/presentation/viewmodels/hsp_modify_viewmodel.dart';
import '../features/health_screening/presentation/viewmodels/hsp_view_viewmodel.dart';
import '../features/medical_record/presentation/viewmodels/mr_upload_viewmodel.dart';
import '../features/medical_record/presentation/viewmodels/mr_view_viewmodel.dart';
import '../features/notification/presentation/viewmodels/notification_viewmodel.dart';
import '../features/profile/viewmodels/patient_viewmodel.dart';
import '../features/home/viewmodels/home_viewmodel.dart';
import '../features/profile/viewmodels/emergency_contact_viewmodel.dart';

import '../features/prescription/data/prescription_service.dart';
import '../features/prescription/data/prescription_repository.dart';
import '../features/prescription/presentation/viewmodels/presc_view_viewmodel.dart';
import '../features/prescription/presentation/viewmodels/presc_modify_viewmodel.dart';

List<SingleChildWidget> get mainProviders {
  return [
    //▫️API
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => AuthenticationRepository()),

    //▫️Services
    Provider(create: (context) => AdminAccountService(apiClient: context.read())),
    Provider(create: (context) => UserAccountService(apiClient: context.read())),
    Provider(create: (context) => AppointmentService(apiClient: context.read())),
    Provider(create: (context) => apt_notif.AppointmentNotificationService(apiClient: context.read())),
    Provider(create: (context) => PublicHolidayService(apiClient: context.read())),
    Provider(create: (context) => DoctorService(apiClient: context.read())),
    Provider(create: (context) => SpecialityService(apiClient: context.read())),
    Provider(create: (context) => HealthScreeningService(apiClient: context.read())),
    Provider(create: (context) => CarouselPosterService(apiClient: context.read())),
    Provider(create: (context) => MedicalRecordService(apiClient: context.read())),
    Provider(create: (context) => EmergencyContactService(apiClient: context.read())),
    Provider(create: (context) => PrescriptionService(apiClient: context.read())),
    // NEW: In-app notification service
    Provider(create: (context) => NotificationService(apiClient: context.read())),

    //▫️Repositories
    Provider(create: (context) => UserRepository(userService: context.read())),
    Provider(create: (context) => AppointmentRepository(appointmentService: context.read())),
    Provider(create: (context) => PublicHolidayRepository(holidayService: context.read())),
    Provider(create: (context) => DoctorRepository(doctorService: context.read())),
    Provider(create: (context) => SpecialityRepository(specialityService: context.read())),
    Provider(create: (context) => HealthScreeningRepository(healthScreeningService: context.read())),
    Provider(create: (context) => CarouselPosterRepository(carouselPosterService: context.read())),
    Provider(create: (context) => MedicalRecordRepository(medicalRecordService: context.read())),
    Provider(create: (context) => PrescriptionRepository(prescriptionService: context.read())),
    // NEW: Notification repository
    Provider(create: (context) => NotificationRepository(notificationService: context.read())),

    //▫️Account Session
    ChangeNotifierProvider(
      create: (context) => AccountSession(
        authRepository: context.read(),
        adminService: context.read(),
        userService: context.read(),
      ),
    ),

    //▫️View models
    ChangeNotifierProvider(
      create: (context) => AuthenticationAccountViewModel(
        authRepository: context.read(),
        userService: context.read(),
        adminService: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => VerificationViewModel(
        authRepository: context.read(),
        accountSession: context.read(),
      ),
    ),

    //🔹Appointment
    ChangeNotifierProvider(
      create: (context) => AppointmentViewModel(
        appointmentRepository: context.read(),
        doctorRepository: context.read(),
        userRepository: context.read(),
        accountSession: context.read(),
        holidayRepository: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => AppointmentModifyViewModel(
        appointmentRepository: context.read(),
        accountSession: context.read(),
        notificationService: context.read(),
      ),
    ),

    //🔹Doctor
    ChangeNotifierProvider(
      create: (context) => DoctorViewModel(
        doctorRepository: context.read(),
        specialityRepository: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => DoctorModifyViewModel(
        doctorRepository: context.read(),
        accountSession: context.read(),
      ),
    ),

    //🔹Health Screening
    ChangeNotifierProvider(
      create: (context) => HealthScreeningViewModel(
        healthScreeningRepository: context.read(),
        carouselPosterRepository: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => HealthScreeningModifyViewModel(
        healthScreeningRepository: context.read(),
        accountSession: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => CarouselEditViewModel(
        carouselPosterRepository: context.read(),
        accountSession: context.read(),
      ),
    ),

    //🔹Medical record
    ChangeNotifierProvider(
      create: (context) => MedicalRecordViewModel(
        medicalRepository: context.read(),
        accountSession: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => MedicalRecordUploadViewModel(
        medicalRepository: context.read(),
        accountSession: context.read(),
      ),
    ),

    //🔹Prescription
    ChangeNotifierProvider(
      create: (context) => PrescriptionViewModel(
        prescriptionRepository: context.read(),
        accountSession: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => PrescriptionModifyViewModel(
        prescriptionRepository: context.read(),
        accountSession: context.read(),
      ),
    ),

    //🔹User
    ChangeNotifierProvider(
      create: (context) => PatientViewModel(
        userRepository: context.read(),
        accountSession: context.read(),
      ),
    ),

    //🔹Home
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        accountSession: context.read(),
        appointmentRepository: context.read(),
        healthScreeningRepository: context.read(),
      ),
    ),

    //🔹Emergency Contact
    ChangeNotifierProvider(
      create: (context) => EmergencyContactViewModel(
        contactService: context.read(),
        accountSession: context.read(),
      ),
    ),

    // NEW: In-app notification viewmodel
    ChangeNotifierProvider(
      create: (context) => NotificationViewModel(
        notificationRepository: context.read(),
        accountSession: context.read(),
      ),
    ),
  ];
}
