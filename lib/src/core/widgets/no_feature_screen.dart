import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Feature {
  appointmentU, // Appointment tracking screen (User)
  appointmentA, // Appointment pending/requested screen (Admin)
  doctors,
  packages,
  information,
  report,
  prescription,
}

class NoFeatureScreen extends StatelessWidget {
  final Feature screenFeature;
  const NoFeatureScreen({super.key, required this.screenFeature});

  @override
  Widget build(BuildContext context) {
    // Use for contents of the app based on the feature
    late String image;
    late String message;

    switch (screenFeature) {
      case Feature.appointmentU:
        image = 'assets/images/noAppointmentScreen.png';
        message = 'No appointments booked. \nYour schedule’s wide open!';

      case Feature.appointmentA:
        image = 'assets/images/noAppointmentScreen.png';
        message = 'No appointments to approve yet. \nCheck back later!';

      case Feature.doctors:
        image =
            'assets/images/noMessageScreen.png'; // Repurposed, can change to a more suitable picture
        message = 'No doctors to view \nat the moment.';

      case Feature.packages:
        image = 'assets/images/noPackagesScreen.png';
        message = 'No packages available right now. \nCome back later!';

      case Feature.information:
        image = 'assets/images/noInboxScreen.png';
        message = 'Nothing in your inbox yet. \nCheck back later!';

      case Feature.report:
        image = 'assets/images/noPrescriptionScreen.png';
        message = 'No medical reports to view \nat the moment.';

      case Feature.prescription:
        image = 'assets/images/noPrescriptionScreen.png';
        message = 'No health prescriptions to view \nat the moment.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, width: 250, height: 250, fit: BoxFit.contain),

          Transform.translate(
            offset: const Offset(0, -30),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
