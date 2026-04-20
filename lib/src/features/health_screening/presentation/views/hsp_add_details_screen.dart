// Info: Admin screen to add a new health screening package, including category.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/hsp_modify_viewmodel.dart';
import '../viewmodels/hsp_view_viewmodel.dart';
import '../../domain/health_screening.dart';
import '../../domain/health_screening_validators.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/input_formatters.dart';

// ── Shared category list (keep in sync with hsp_detail_screen.dart) ──────────
const List<String> kHealthPackageCategories = [
  'General',
  'Special Programme',
  'Specialized',
];

class HealthScreeningAddDetailScreen extends StatefulWidget {
  const HealthScreeningAddDetailScreen({super.key});

  @override
  State<HealthScreeningAddDetailScreen> createState() =>
      _HealthScreeningAddDetailScreenState();
}

class _HealthScreeningAddDetailScreenState
    extends State<HealthScreeningAddDetailScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>();

  // Form Inputs:
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _includedController;
  File? _image;
  String? _selectedCategory; // NEW

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    _nameController        = TextEditingController();
    _priceController       = TextEditingController();
    _descriptionController = TextEditingController();
    _includedController    = [TextEditingController()];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    for (final c in _includedController) {
      c.dispose();
    }
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<HealthScreeningModifyViewModel>();
    final vmData   = context.read<HealthScreeningViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
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
            'Add Health Package',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE6E6E6), height: 1),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Image picker ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: buildImageField(
                    onTap: () async {
                      final result = await vmModify.pickImage();
                      if (!context.mounted) return;
                      switch (result) {
                        case Ok<File?>():
                          final image = result.value;
                          if (image != null) {
                            setState(() => _image = image);
                            showSnackBar(
                              context: context,
                              text: "Image file successfully picked.",
                            );
                          } else {
                            showSnackBar(
                              context: context,
                              text: "No file was picked.",
                            );
                          }
                        case Error<File?>():
                          showSnackBar(
                            context: context,
                            text: vmModify.message ??
                                "An unknown error occured. Please try again.",
                            color: Colors.red[900],
                          );
                      }
                    },
                    cache: _image,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Package details ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField(
                        label: 'Package Title',
                        controller: _nameController,
                        hintText: "Enter package title",
                        validator: (v) =>
                            HealthScreeningValidators.isNameValid(v),
                        inputFormatter: [InputFormat.noLeadingWhitespace],
                      ),
                      const SizedBox(height: 12),

                      buildTextField(
                        label: "Price (RM)",
                        controller: _priceController,
                        hintText: "Enter price (e.g: 199.99)",
                        validator: (v) =>
                            HealthScreeningValidators.isPriceValid(v),
                        inputFormatter: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Category dropdown ── NEW ────────────────────────
                      buildCategoryDropdown(),
                      const SizedBox(height: 12),

                      buildTextField(
                        label: "Description",
                        controller: _descriptionController,
                        hintText: "Enter package description",
                        maxLines: 4,
                        validator: (v) =>
                            HealthScreeningValidators.isDescriptionValid(v),
                      ),
                    ],
                  ),
                ),

                // ── What's Included ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's Included",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          for (int i = 0;
                              i < _includedController.length;
                              i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF6FCF97),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: buildTextField(
                                      label: "",
                                      controller: _includedController[i],
                                      hintText: "Enter included item",
                                      validator: (v) =>
                                          HealthScreeningValidators
                                              .isIncludedValid(v),
                                      inputFormatter: [
                                        InputFormat.noLeadingWhitespace,
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (_includedController.length > 1) {
                                        setState(() =>
                                            _includedController.removeAt(i));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _includedController
                                  .add(TextEditingController()));
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add point"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── Save button ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FBF73),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _image != null &&
                            _includedController.isNotEmpty) {
                          if (_selectedCategory == null) {
                            showSnackBar(
                              context: context,
                              text: "Please select a package category.",
                              color: Colors.red[900],
                            );
                            return;
                          }

                          final saveData = HealthScreening(
                            id: 0,
                            name: _nameController.text.trim(),
                            price: double.parse(
                                  _priceController.text.trim(),
                                ) *
                                100,
                            description:
                                _descriptionController.text.trim(),
                            included: _includedController
                                .map((c) => c.text.trim())
                                .toList(),
                            image: '',
                            category: _selectedCategory, // NEW
                            archived: false,
                            updatedAt: DateTime.timestamp(),
                          );

                          final result =
                              await vmModify.addPackage(saveData, _image!);

                          if (!context.mounted) return;

                          switch (result) {
                            case Ok():
                              showSuccessDialog(
                                context: context,
                                title: "New Health Screening Package Created!",
                                message:
                                    "The ${saveData.name}'s details has been successfully added.",
                                onButtonPressed: () {
                                  vmData.load();
                                  Navigator.of(context).popUntil((route) {
                                    return route.settings.name ==
                                            '/packageModifyList' ||
                                        route.isFirst;
                                  });
                                },
                              );
                            case Error():
                              showSnackBar(
                                context: context,
                                text: vmModify.message ??
                                    "An unknown error occured. Please try again.",
                                color: Colors.red[900],
                              );
                          }
                        } else {
                          showSnackBar(
                            context: context,
                            text: _image == null
                                ? "Please upload a package image."
                                : "Your submission is unfinished or invalid. Please check and try again.",
                            color: Colors.red[900],
                          );
                        }
                      },
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  // Category dropdown — NEW
  Widget buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              hint: Text(
                'Select a category',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6FBF73),
              ),
              items: kHealthPackageCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat,
                    style:
                        const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
          ),
        ),
      ],
    );
  }

  // Image Field
  Widget buildImageField({
    required void Function()? onTap,
    required File? cache,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6FBF73), width: 2),
              image: DecorationImage(
                image: (cache == null)
                    ? const AssetImage('assets/images/si.png')
                    : FileImage(cache) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 20,
                color: Color(0xFF6FBF73),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stylized text field
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            inputFormatters: inputFormatter,
            style: const TextStyle(color: Colors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
                  TextStyle(color: Colors.grey[600], fontSize: 15),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
