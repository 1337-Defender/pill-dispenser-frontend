import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pill_dispenser/providers/auth_provider.dart';
import 'package:pill_dispenser/screens/auth/auth_settings_popover.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _customName;
  String? _customDescription;
  int _strength = 10;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(LucideIcons.chevronLeft, color: Colors.black),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            LucideIcons.bell,
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: Icon(LucideIcons.userRound, color: Colors.black),
                          onPressed:
                                () => showPopover(
                                  width: 100,
                                  height: 100,
                                  backgroundColor: Colors.white,
                                  context: context,
                                  bodyBuilder: (context) => AuthSettingsPopover(),
                                ),
                        );
                      }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Add medication",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: Text(
                    "Select from store",
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  items: const [],
                  onChanged: (value) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[700],)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "OR",
                        style: GoogleFonts.inter(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[700],)),
                  ],
                ),
              ),
              Text(
                "Custom",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Name",
                          hintText: "Enter medication name...",
                          labelStyle: GoogleFonts.inter(),
                          hintStyle: GoogleFonts.inter(),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSaved: (val) => _customName = val,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Enter medication name...",
                          labelStyle: GoogleFonts.inter(),
                          hintStyle: GoogleFonts.inter(),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSaved: (val) => _customDescription = val,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Strength",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (_strength > 1) _strength -= 1;
                              });
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "$_strength mg",
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _strength += 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable button while loading
                      : () async {
                          final form = _formKey.currentState;
                          if (form != null && form.validate()) {
                            form.save();

                            // Set loading state to true
                            setState(() {
                              _isLoading = true;
                            });

                            // Get current user id from your AuthProvider
                            final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User not logged in')),
                              );
                              setState(() {
                                _isLoading = false; // Reset loading state
                              });
                              return;
                            }

                            final response = await Supabase.instance.client
                                .from('medications')
                                .insert({
                                  'user_id': userId,
                                  'custom_name': _customName,
                                  'custom_description': _customDescription,
                                  'custom_strength': '$_strength mg',
                                })
                                .select()
                                .single();

                            if (response != null && response['id'] != null) {
                              // Success
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Medication added!')),
                              );
                              Navigator.of(context).pop();
                            } else {
                              // Error
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to add medication')),
                              );
                            }

                            // Reset loading state
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFFF3D),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Submit", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
