import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import 'widget/edit_personal_box.dart';
import '../domain/emergency_contact.dart';
import '../viewmodels/emergency_contact_viewmodel.dart';
import '../../authentication/data/account_session.dart';
import '../../authentication/domain/user.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/loading_screen.dart';
import '../../../utils/data/results.dart';
import '../../../utils/ui/show_snackbar.dart';
import '../../../utils/ui/show_success_dialogue.dart';

class EditEmergencyContactScreen extends StatefulWidget {
  const EditEmergencyContactScreen({
    super.key,
    required this.patientUser,
    required this.contact,
  });

  final User patientUser;
  final EmergencyContact? contact;

  @override
  State<EditEmergencyContactScreen> createState() =>
      _EditPersonalDScreenState();
}

class _EditPersonalDScreenState extends State<EditEmergencyContactScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>(); // Form key

  // Form inputs
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController relationshipController;

  String? _selectedRelationship;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    final contact = widget.contact;

    // Initialize depending on edit existing info or adding new info
    if (contact != null) {
      nameController = TextEditingController(text: contact.name);
      emailController = TextEditingController(text: contact.email);
      phoneController = TextEditingController(text: contact.phoneNumber);
      addressController = TextEditingController(text: contact.homeAddress);
      relationshipController = TextEditingController(
        text: contact.relationship,
      );
    } else {
      nameController = TextEditingController();
      emailController = TextEditingController();
      phoneController = TextEditingController();
      addressController = TextEditingController();
      relationshipController = TextEditingController();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vm = context.watch<EmergencyContactViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(235, 165, 165, 165),
          centerTitle: true,
          title: Text(
            'Edit Emergency Contact',
            textAlign: TextAlign.center,
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
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      bottom: 10.0,
                    ),
                    child: const EditPersonalDetailsBox(),
                  ),

                  const SizedBox(height: 5),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                  ),

                  inputField(
                    nameController,
                    'Full Name',
                    readOnly: session.role == UserRole.admin,
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter your contact's full name"
                        : null,
                  ),

                  // Relationship dropdown
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final List<String> relationships = [
                          'Father',
                          'Mother',
                          'Brother',
                          'Sister',
                          'Spouse',
                          'Friend',
                          'Other',
                        ];

                        // Preselect if controller has value
                        if (_selectedRelationship == null &&
                            relationshipController.text.isNotEmpty) {
                          _selectedRelationship = relationshipController.text;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'Relationship with Contact',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                value: _selectedRelationship,
                                hint: Text(
                                  'Select relationship',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF9E9E9E),
                                    fontSize: 14,
                                  ),
                                ),
                                items: relationships.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: SizedBox(
                                      width: constraints.maxWidth - 32,
                                      child: Text(
                                        item,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (session.role == UserRole.user) {
                                    setState(() {
                                      _selectedRelationship = value;
                                      relationshipController.text = value ?? '';
                                    });
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: constraints.maxWidth,
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xffefefef),
                                      width: 1.5,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey[700],
                                    size: 28,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 300,
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  offset: const Offset(0, -8),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness:
                                        MaterialStateProperty.all<double>(4),
                                    thumbVisibility:
                                        MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 48,
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  inputField(
                    emailController,
                    'Email',
                    readOnly: session.role == UserRole.admin,
                  ),

                  inputField(
                    phoneController,
                    'Mobile Phone',
                    keyboardType: TextInputType.phone,
                    readOnly: session.role == UserRole.admin,
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full Address',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 5, 5, 5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          maxLines: 5,
                          readOnly: session.role == UserRole.admin,
                          decoration: InputDecoration(
                            hintText: (session.role == UserRole.user)
                                ? 'Enter full address including postcode, city, and state'
                                : '',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF629E5C),
                              ),
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save button
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (session.role == UserRole.user)
                          ? () async {
                              if (_formKey.currentState!.validate() &&
                                  _selectedRelationship != null) {
                                final saveData = EmergencyContact(
                                  id: widget.contact?.id ?? 0,
                                  name: nameController.text.trim(),
                                  relationship: _selectedRelationship!,
                                  email: emailController.text.trim(),
                                  phoneNumber: phoneController.text.trim(),
                                  homeAddress: addressController.text.trim(),
                                  userId:
                                      widget.contact?.userId ??
                                      widget.patientUser.id,
                                  updatedAt: DateTime.timestamp(),
                                );

                                if (widget.contact == null) {
                                  // Create new emergency contact
                                  final result = await vm.addContact(saveData);

                                  if (!context.mounted) return;

                                  if (result is Ok) {
                                    showSuccessDialog(
                                      context: context,
                                      title: "Emergenct Contact Added!",
                                      message:
                                          "Your emergency contact's information has been successfully created.",
                                      onButtonPressed: () {
                                        vm.load(widget.patientUser.id);
                                        Navigator.of(context).popUntil((route) {
                                          return route.settings.name ==
                                                  '/profile' ||
                                              route.isFirst;
                                        });
                                      },
                                    );
                                  } else {
                                    showSnackBar(
                                      context: context,
                                      text:
                                          vm.message ??
                                          "An unknown error occured. Please try again.",
                                      color: Colors.red[900],
                                    );
                                  }
                                } else {
                                  // Edit emergency contact
                                  final result = await vm.editContact(saveData);

                                  if (!context.mounted) return;

                                  if (result is Ok) {
                                    showSuccessDialog(
                                      context: context,
                                      title: "Emergenct Contact Changed!",
                                      message:
                                          "Your emergency contact's information has been successfully changed.",
                                      onButtonPressed: () {
                                        vm.load(widget.patientUser.id);
                                        Navigator.of(context).popUntil((route) {
                                          return route.settings.name ==
                                                  '/profile' ||
                                              route.isFirst;
                                        });
                                      },
                                    );
                                  } else {
                                    showSnackBar(
                                      context: context,
                                      text:
                                          vm.message ??
                                          "An unknown error occured. Please try again.",
                                      color: Colors.red[900],
                                    );
                                  }
                                }
                              } else {
                                showSnackBar(
                                  context: context,
                                  text:
                                      "Your submission is unfinished or invalid, Please check and try again.",
                                  color: Colors.red[900],
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (session.role == UserRole.admin)
                            ? Colors.grey[400]
                            : Color(0xFF629E5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm Changes',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //▫️Helper Widget:
  // Input field widget
  Widget inputField(
    TextEditingController controller,
    String title, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title label above the box
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromARGB(255, 5, 5, 5),
              ),
            ),
          ),
          // Text field box
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 1,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xffefefef),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF629E5C),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red.shade900, width: 2),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
