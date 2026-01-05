import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nexus_kyt/auth_provider.dart';
import 'package:nexus_kyt/background_video_provider.dart';
import 'package:nexus_kyt/id_card_screen.dart';
import 'package:nexus_kyt/services/api_service.dart';
import 'package:provider/provider.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? gender;
  String? maritalStatus;
  String? disability;

  // ✅ Keep controllers here so they persist
  // Profile fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Date of birth controllers
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

// Current Address controllers
  final TextEditingController currentStreet1 = TextEditingController();
  final TextEditingController currentStreet2 = TextEditingController();
  final TextEditingController currentCity = TextEditingController();
  final TextEditingController currentRegion = TextEditingController();
  final TextEditingController currentProvince = TextEditingController();
  final TextEditingController currentPostal = TextEditingController();
  final TextEditingController currentNationality = TextEditingController();

// Permanent Address controllers
  final TextEditingController permStreet1 = TextEditingController();
  final TextEditingController permStreet2 = TextEditingController();
  final TextEditingController permCity = TextEditingController();
  final TextEditingController permRegion = TextEditingController();
  final TextEditingController permProvince = TextEditingController();
  final TextEditingController permPostal = TextEditingController();
  final TextEditingController permNationality = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mark that user is on ProfileFormScreen
    Future.microtask(() {
      context.read<AuthProvider>().setCurrentScreen('profile_form');
    });
  }

  @override
  void dispose() {
    // ✅ Always dispose controllers
    fullNameController.dispose();
    fatherNameController.dispose();
    nationalIdController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    currentStreet1.dispose();
    currentStreet2.dispose();
    currentCity.dispose();
    currentRegion.dispose();
    currentProvince.dispose();
    currentPostal.dispose();
    currentNationality.dispose();
    permStreet1.dispose();
    permStreet2.dispose();
    permCity.dispose();
    permRegion.dispose();
    permProvince.dispose();
    permPostal.dispose();
    permNationality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool sameAsCurrent = false;
    final videoProvider = Provider.of<BackgroundVideoProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: BlockchainBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: 0.33,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 10),
                const Text("Step 1 of 3",
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 20),

                // Form container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Profile Detail",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("Please complete your personal information",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 20),

                        // Full Name
                        const Text("Full Name",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Enter your full name",
                            controller: fullNameController),

                        const Text("Father's Name",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Enter father's name",
                            controller: fatherNameController),

                        const Text("National Identity (CNIC/ID)",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Enter CNIC/ID",
                            controller: nationalIdController),

                        const Text("Date of Birth",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                  context, "Day", dayController),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDateField(
                                  context, "Month", monthController),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDateField(
                                  context, "Year", yearController),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(DateTime.now().year - 18,
                                      12, 31), // must be 18+
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    dayController.text = pickedDate.day
                                        .toString()
                                        .padLeft(2, '0');
                                    monthController.text = pickedDate.month
                                        .toString()
                                        .padLeft(2, '0');
                                    yearController.text =
                                        pickedDate.year.toString();
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today),
                            ),
                          ],
                        ),

                        const Text("Phone Number",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Enter phone number",
                            controller: phoneNumberController),

                        const Text("Email",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Enter email",
                            controller: emailController),

                        const SizedBox(height: 12),
                        const Text("Gender",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => gender = "Male"),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: gender == "Male"
                                        ? Color.fromARGB(255, 196, 228, 255)
                                        : Colors.transparent,
                                    border:
                                        Border.all(color: Colors.blue.shade900),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Male",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => gender = "Female"),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: gender == "Female"
                                        ? Color.fromARGB(255, 196, 228, 255)
                                        : Colors.transparent,
                                    border:
                                        Border.all(color: Colors.blue.shade900),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Female",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => gender = "Other"),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: gender == "Other"
                                        ? Color.fromARGB(255, 196, 228, 255)
                                        : Colors.transparent,
                                    border:
                                        Border.all(color: Colors.blue.shade900),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Other",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Text("Current Address",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text("Street Address",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Street Address",
                            controller: currentStreet1),
                        const Text("Street Address Line 2",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Street Address Line 2",
                            controller: currentStreet2),

                        // City & Region
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("City",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("City",
                                      controller: currentCity),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Region",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("Region",
                                      controller: currentRegion),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Province",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("Province",
                                      controller: currentProvince),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Postal Code",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("Postal Code",
                                      controller: currentPostal,
                                      isNumber: true),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Text("Nationality",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Nationality",
                            controller: currentNationality),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Permanent Address",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Switch(
                              value: sameAsCurrent,
                              activeColor: Colors.blue.shade900,
                              onChanged: (value) {
                                setState(() {
                                  sameAsCurrent = value;

                                  if (sameAsCurrent) {
                                    // Copy current -> permanent
                                    permStreet1.text = currentStreet1.text;
                                    permStreet2.text = currentStreet2.text;
                                    permCity.text = currentCity.text;
                                    permRegion.text = currentRegion.text;
                                    permProvince.text = currentProvince.text;
                                    permPostal.text = currentPostal.text;
                                    permNationality.text =
                                        currentNationality.text;
                                  } else {
                                    // Clear if unchecked
                                    permStreet1.clear();
                                    permStreet2.clear();
                                    permCity.clear();
                                    permRegion.clear();
                                    permProvince.clear();
                                    permPostal.clear();
                                    permNationality.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),

                        const Text("Street Address",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Street Address",
                            controller: permStreet1),
                        const Text("Street Address Line 2",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Street Address Line 2",
                            controller: permStreet2),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("City",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("City", controller: permCity),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Region",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("Region",
                                      controller: permRegion),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Province",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("Province",
                                      controller: permProvince),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Postal Code",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  _buildTextField("Postal Code",
                                      controller: permPostal, isNumber: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Text("Nationality",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        _buildTextField("Nationality",
                            controller: permNationality),

                        const SizedBox(height: 20),
                        const Text("Other",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildDropdown(
                            "Marital Status",
                            ["Single", "Married", "Divorced"],
                            maritalStatus,
                            (val) => setState(() => maritalStatus = val)),
                        _buildDropdown(
                            "Disability",
                            ["None", "Yes"],
                            disability,
                            (val) => setState(() => disability = val)),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Collect all form data
                                          final profileData = {
                                            "fullName":
                                                fullNameController.text.trim(),
                                            "fatherName": fatherNameController
                                                .text
                                                .trim(),
                                            "nationalIdentity":
                                                nationalIdController.text
                                                    .trim(),
                                            "birthDay": dayController.text,
                                            "birthMonth": monthController.text,
                                            "birthYear": yearController.text,
                                            "phoneNumber": phoneNumberController
                                                .text
                                                .trim(),
                                            "email":
                                                emailController.text.trim(),
                                            "gender": gender ?? "",
                                            "currentStreetAddress1":
                                                currentStreet1.text.trim(),
                                            "currentStreetAddress2":
                                                currentStreet2.text.trim(),
                                            "currentCity":
                                                currentCity.text.trim(),
                                            "currentRegion":
                                                currentRegion.text.trim(),
                                            "currentProvince":
                                                currentProvince.text.trim(),
                                            "currentPostalCode":
                                                currentPostal.text.trim(),
                                            "currentNationality":
                                                currentNationality.text.trim(),
                                            "permanentStreetAddress1":
                                                permStreet1.text.trim(),
                                            "permanentStreetAddress2":
                                                permStreet2.text.trim(),
                                            "permanentCity":
                                                permCity.text.trim(),
                                            "permanentRegion":
                                                permRegion.text.trim(),
                                            "permanentProvince":
                                                permProvince.text.trim(),
                                            "permanentPostalCode":
                                                permPostal.text.trim(),
                                            "permanentNationality":
                                                permNationality.text.trim(),
                                            "maritalStatus":
                                                maritalStatus ?? "",
                                            "disability": disability ?? "",
                                          };

                                          // Submit to API via AuthProvider so loading state is handled
                                          final result = await authProvider
                                              .submitProfile(data: profileData);

                                          if (result['success']) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Profile submitted successfully!'),
                                                backgroundColor:
                                                    Colors.green.shade700,
                                              ),
                                            );

                                            // Navigate to next screen
                                            if (mounted) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 250),
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const IdCardUploadScreen(),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    const begin =
                                                        Offset(1.0, 0.0);
                                                    const end = Offset.zero;
                                                    const curve =
                                                        Curves.easeInOut;

                                                    final tween = Tween(
                                                            begin: begin,
                                                            end: end)
                                                        .chain(CurveTween(
                                                            curve: curve));
                                                    final offsetAnimation =
                                                        animation.drive(tween);

                                                    return SlideTransition(
                                                      position: offsetAnimation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(result['error'] ??
                                                    'Failed to submit profile'),
                                                backgroundColor:
                                                    Colors.red.shade700,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      EdgeInsets.zero, // remove default padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // rounded corners
                                  ),
                                  backgroundColor: Colors
                                      .transparent, // remove default solid color
                                  shadowColor: Colors
                                      .transparent, // remove shadow to see gradient clearly
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(
                                            255, 18, 18, 111), // Dark Blue
                                        Color(0xFF1cb5e0), // Light Blue
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height *
                                        0.065,
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Text(
                                            'Submit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {TextEditingController? controller, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : [], // only numbers
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.018,
            horizontal: MediaQuery.of(context).size.width * 0.01,
          ),
        ),
        validator: (val) =>
            val == null || val.isEmpty ? "$hint is required" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Select $label" : null,
      ),
    );
  }
}

Widget _buildDateField(
    BuildContext context, String hint, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number, // numeric keyboard
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.018,
          horizontal: MediaQuery.of(context).size.width * 0.01,
        ),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? "$hint is required" : null,
    ),
  );
}
