import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/hsp_modify_viewmodel.dart';
import '../viewmodels/hsp_view_viewmodel.dart';
import '../../domain/health_screening.dart';
import '../../domain/health_screening_validators.dart';
import '../../../authentication/data/account_session.dart';
import '../../../appointment/presentation/views/apt_booking_screen.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/input_formatters.dart';
import 'hsp_add_details_screen.dart' show kHealthPackageCategories;

class HealthScreeningDetailViewScreen extends StatefulWidget {
  const HealthScreeningDetailViewScreen({
    super.key,
    required this.mode,
    required this.package,
  });

  final ScreenRole mode;
  final HealthScreening package;

  @override
  State<HealthScreeningDetailViewScreen> createState() =>
      _PackageDetailsScreenState();
}

class _PackageDetailsScreenState
    extends State<HealthScreeningDetailViewScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>(); // Form key
  bool editing = false; // Value to change screen mode

  // Editable fields
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _includedController;
  late ImageProvider _imageController;
  File? _image;
  String? _selectedCategory; // NEW — tracks chosen category in edit mode

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.package.name);
    _priceController = TextEditingController(
      text: widget.package.price.toStringAsFixed(2),
    );

    _descriptionController = TextEditingController(
      text: widget.package.description,
    );

    _includedController = widget.package.included
        .map((text) => TextEditingController(text: text))
        .toList();

    _imageController = NetworkImage(widget.package.image);

    // Pre-select the category that was saved for this package
    _selectedCategory = (widget.package.category != null &&
            kHealthPackageCategories.contains(widget.package.category))
        ? widget.package.category
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    for (final i in _includedController) {
      i.dispose();
    }
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vmModify = context.watch<HealthScreeningModifyViewModel>();
    final vmData = context.read<HealthScreeningViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf9fafb),
          elevation: 0,
          toolbarHeight: 65,
          surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Package Details',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: const Color(0xFFE6E6E6), // light grey divider
              height: 1,
            ),
          ),
          actions: [
            if (session.role == UserRole.admin &&
                widget.mode == ScreenRole.edit)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: TextButton(
                  onPressed: () {
                    setState(() => editing = !editing);
                  },
                  child: Text(
                    editing ? "Done" : "Edit",
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SECTION - White background
                Container(
                  color: Colors.white,
                  child: editing
                      ? Padding(
                          padding: const EdgeInsets.all(0),
                          child: buildEditableImage(
                            onTap: () async {
                              final result = await vmModify.pickImage();

                              if (!context.mounted) return;

                              switch (result) {
                                case Ok<File?>():
                                  final image = result.value;
                                  String message;

                                  // File picked or cancelled
                                  if (image != null) {
                                    setState(() {
                                      _image = image;
                                      _imageController = FileImage(image);
                                    });
                                    message = "Image file successfully picked.";
                                  } else {
                                    message = "No file was picked.";
                                  }

                                  showSnackBar(context: context, text: message);
                                case Error<File?>():
                                  showSnackBar(
                                    context: context,
                                    text:
                                        vmModify.message ??
                                        "An unknown error occured. Please try again.",
                                    color: Colors.red[900],
                                  );
                              }
                            },
                            imgCtrl: _imageController,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 240,
                          padding: const EdgeInsets.only(top: 0),
                          child: Image(
                            image: _imageController,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),

                const SizedBox(height: 0),

                // MAIN CONTENT SECTION - White card with subtle shadow
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      editing
                          ? buildEditableTextField(
                              _nameController,
                              validator: (value) =>
                                  HealthScreeningValidators.isNameValid(value),
                              inputFormatter: [InputFormat.noLeadingWhitespace],
                            )
                          : Text(
                              _nameController.text,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                      const SizedBox(height: 12),

                      // PRICE BADGE
                      editing
                          ? buildEditableTextField(
                              _priceController,
                              validator: (value) =>
                                  HealthScreeningValidators.isPriceValid(value),
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            )
                          : // NOTE: Assuming priceCtrl is a TextEditingController containing the price string.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 5,
                              ), // Increased padding slightly
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                  255,
                                  242,
                                  250,
                                  242,
                                ), // A very light, professional off-white/grey-green
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Standard professional radius
                                border: Border.all(
                                  color: const Color(0xFF6FBF73),
                                  width: 0.5,
                                ), // Subtle, light border
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.00,
                                    ), // Very soft shadow for lift
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Essential to keep the container size tight to content
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  // Currency Symbol (Slightly smaller, lighter)
                                  Text(
                                    'RM', // Placeholder for Malaysian Ringgit (or use your required currency)
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(
                                        0xFF6FBF73,
                                      ), // Muted green for supporting text
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Price Value (Largest, boldest text)
                                  Text(
                                    _priceController.text,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20, // Slightly larger font size
                                      fontWeight: FontWeight
                                          .w700, // Extra bold for emphasis
                                      color: const Color(
                                        0xFF6FBF73,
                                      ), // Deep, formal green
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 20),

                      // SECTION DIVIDER
                      if (!editing)
                        const Divider(color: Color(0xFFF0F0F0), height: 1),
                      if (!editing) const SizedBox(height: 20),

                      // CATEGORY — NEW ──────────────────────────────────
                      editing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  'Category',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      hint: Text(
                                        'Select a category',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF6FBF73),
                                      ),
                                      items: kHealthPackageCategories
                                          .map((cat) => DropdownMenuItem(
                                                value: cat,
                                                child: Text(
                                                  cat,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedCategory = val),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            )
                          : widget.package.category != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6FBF73)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF6FBF73)
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          widget.package.category!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                const Color(0xFF4D7C4A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),

                      // DESCRIPTION
                      editing
                          ? buildEditableTextField(
                              _descriptionController,
                              maxLines: 4,
                              validator: (value) =>
                                  HealthScreeningValidators.isDescriptionValid(
                                    value,
                                  ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6FBF73),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.description,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Description",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _descriptionController.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // WHAT'S INCLUDED SECTION - Different background
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6FBF73),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "What's Included",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      editing
                          ? Column(
                              children: [
                                for (
                                  int i = 0;
                                  i < _includedController.length;
                                  i++
                                )
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
                                          child: buildEditableTextField(
                                            _includedController[i],
                                            validator: (value) =>
                                                HealthScreeningValidators.isIncludedValid(
                                                  value,
                                                ),
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
                                          onPressed: () => setState(() {
                                            _includedController.removeAt(i);
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                TextButton.icon(
                                  onPressed: () => setState(() {
                                    _includedController.add(
                                      TextEditingController(text: ""),
                                    );
                                  }),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add point"),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                for (var ctrl in _includedController)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFF0F0F0),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF6FCF97),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            ctrl.text,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              height: 1.5,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child:
                        // Change button type and function
                        editing
                        ? ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  _includedController.isNotEmpty) {
                                final saveData = HealthScreening(
                                  id: widget.package.id,
                                  name: _nameController.text.trim(),
                                  price:
                                      double.parse(
                                        _priceController.text.trim(),
                                      ) *
                                      100,
                                  description: _descriptionController.text
                                      .trim(),
                                  included: _includedController
                                      .map((items) => items.text.trim())
                                      .toList(),
                                  image: widget.package.image,
                                  category: _selectedCategory, // NEW
                                  archived: false,
                                  updatedAt: widget.package.updatedAt,
                                );

                                final result = await vmModify.editPackage(
                                  saveData,
                                  _image,
                                );

                                if (!context.mounted) return;

                                switch (result) {
                                  case Ok():
                                    showSuccessDialog(
                                      context: context,
                                      title:
                                          "Health Screening Package Updated!",
                                      message:
                                          "The ${saveData.name}'s details has been successfully updated.",
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
                                      text:
                                          vmModify.message ??
                                          "An unknown error occured. Please try again.",
                                      color: Colors.red[900],
                                    );
                                }
                              } else {
                                showSnackBar(
                                  context: context,
                                  text:
                                      "Your submission is unfinished or invalid, Please check and try again.",
                                  color: Colors.red[900],
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6FBF73),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              "Save Changes",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: (session.role == UserRole.admin)
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      transitionAnimation(
                                        page: AuthWrappper(
                                          accessRole: UserRole.user,
                                          child:
                                              const AppointmentBookingScreen(),
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (session.role == UserRole.admin)
                                  ? Colors.grey[400]
                                  : const Color(0xFF6FBF73),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: (session.role == UserRole.admin)
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),

                                Text(
                                  "Request Appointment",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: (session.role == UserRole.admin)
                                        ? Colors.grey[700]
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: (session.role == UserRole.admin)
                        ? null
                        : null, // Add share functionality later for user
                    icon: Icon(
                      Icons.ios_share_rounded,
                      color: Colors.grey[500],
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //▫️Helper Widget:
  // Image field
  Widget buildEditableImage({
    required void Function()? onTap,
    required ImageProvider imgCtrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6FBF73), width: 2),
              image: DecorationImage(image: imgCtrl, fit: BoxFit.cover),
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
              child: const Icon(Icons.edit, size: 20, color: Color(0xFF6FBF73)),
            ),
          ),
        ],
      ),
    );
  }

  // Stylized text field
  Widget buildEditableTextField(
    TextEditingController controller, {
    int maxLines = 1,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatter,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF629E5C)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade900),
        ),
      ),
    );
  }
}
