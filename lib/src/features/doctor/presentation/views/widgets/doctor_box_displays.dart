import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../doctor_detail_view_screen.dart';
import '../../viewmodels/doctor_view_viewmodel.dart';
import '../../../../../config/constants/global_values.dart';
import '../../../../../core/widgets/account_checker.dart';
import '../../../../../core/widgets/icon_box_container.dart';
import '../../../../../core/widgets/no_feature_screen.dart';
import '../../../../../utils/ui/animations_transitions.dart';

class DoctorBoxView extends StatelessWidget {
  const DoctorBoxView({super.key, required this.role});

  final UserRole role;

  // Dynamic scaling functions
  double scaleWidth(BuildContext context, double size) =>
      size * MediaQuery.of(context).size.width / 400; // base width reference

  double scaleHeight(BuildContext context, double size) =>
      size * MediaQuery.of(context).size.height / 800; // base height reference

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.read<DoctorViewModel>();

    return (vm.specialities.isNotEmpty)
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(25),

            // 2. Define the grid layout
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio:
                  1.0, // Adjust this to fit your boxContainer height
            ),

            // 3. Only build what is visible
            itemCount: vm.specialities.length,
            itemBuilder: (context, index) {
              final s = vm.specialities[index];

              return boxContainer(
                text: s.name,
                svgAsset:
                    specialityImageBoxes[s.id] ?? 'assets/svg/doctors.svg',
                iconWidth: scaleWidth(context, 30),
                iconHeight: scaleHeight(context, 50),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: role,
                        child: DoctorDetailViewScreen(speciality: s),
                      ),
                    ),
                  );
                },
              );
            },
          )
        : NoFeatureScreen(screenFeature: Feature.doctors);
  }
}
