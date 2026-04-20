import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../authentication/data/account_session.dart';
import '../../health_screening/domain/health_screening.dart';
import '../../health_screening/presentation/views/hsp_detail_screen.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/account_checker.dart';
import '../../../utils/ui/animations_transitions.dart';

class InfoDetailsScreen extends StatelessWidget {
  const InfoDetailsScreen({super.key, required this.package});

  final HealthScreening package;

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9fafb),
        elevation: 0,
        surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Information Details",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 23,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE6E6E6), // light grey divider
            height: 1,
          ),
        ),
      ),

      // 🔹 Main Scrollable Content
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Full-width image (no border radius, no shadow)
            Image.network(
              package.image,
              fit: BoxFit.cover,
              width: double.infinity,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: Text(
                    "Image Asset Not Found",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              },
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: Color(0xFF7CB342)),
                );
              },
            ),

            // 🔹 Content with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "${package.name} [NEW]",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 18),
                  Text(
                    package.description,
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 100), // space before bottom bar
                ],
              ),
            ),
          ],
        ),
      ),

      //🔹Always visible bottom buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              // Request Appointment Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      transitionAnimation(
                        page: AuthWrappper(
                          accessRole: session.role,
                          child: HealthScreeningDetailViewScreen(
                            mode: ScreenRole.view,
                            package: package,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF6FBF73,
                    ), // Green background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        "More Info",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 🚧 Share button (WIP)
              IconButton(
                onPressed: () {
                  // TODO: Add share logic
                  // Logic 1: Share a link to the more info screen above to others
                  // Logic 2: Share an image of the information including its info
                },
                icon: const Icon(
                  Icons.ios_share_rounded,
                  color: Color(0xFF667085), // Color(0xFF6FBF73)
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
