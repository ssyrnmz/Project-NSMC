import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/core/widgets/loading_screen.dart';
import 'package:provider/provider.dart';

import 'widgets/doctor_detail_row.dart';
import 'widgets/doctor_detail_title.dart';
import '../viewmodels/doctor_view_viewmodel.dart';
import '../../domain/doctor.dart';
import '../../domain/speciality.dart';

class DoctorDetailViewScreen extends StatelessWidget {
  final Speciality speciality;

  const DoctorDetailViewScreen({super.key, required this.speciality});

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      loadingIndicator: false,
      child: buildDoctorDetailTitle(
        context: context,
        screenTitle: speciality.name,
        doctorListScreen: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              for (Doctor d in vm.doctorList(speciality))
                buildDoctorDetailRow(
                  text1: d.name,
                  text2: d.status,
                  text3: d.qualifications,
                  text4: d.specialization,
                  imagePath: d.image ?? 'assets/images/blank.png',
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
