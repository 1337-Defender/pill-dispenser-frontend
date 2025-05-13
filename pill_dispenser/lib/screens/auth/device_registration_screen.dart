import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pill_dispenser/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool isValidUuidV4(String? input) {
  if (input == null || input.isEmpty) {
    return false;
  }

  // Regular expression for UUID v4
  // Explanation:
  // ^                                      Start of string
  // [0-9a-fA-F]{8}-                         8 hex chars followed by a hyphen
  // [0-9a-fA-F]{4}-                         4 hex chars followed by a hyphen
  // 4[0-9a-fA-F]{3}-                       '4' followed by 3 hex chars (version 4) followed by a hyphen
  // [89abAB][0-9a-fA-F]{3}-                One of '8', '9', 'a', 'b' (variant) followed by 3 hex chars followed by a hyphen
  // [0-9a-fA-F]{12}                        12 hex chars
  // $                                      End of string
  final RegExp uuidV4RegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  return uuidV4RegExp.hasMatch(input);
}

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() =>
      _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deviceIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    // TODO: Implement your device registration logic here
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    log('User ID: $userId');
    final deviceId = _deviceIdController.text.trim();

    if (!isValidUuidV4(deviceId))
    {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect Device ID format')));
      return;
    }

    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated.')));
      return;
    }
    final response = await supabase.rpc(
      'assign_dispenser_to_user',
      params: {'input_user_id_to_assign': userId, 'input_dispenser_id': deviceId},
    );
    setState(() => _isLoading = false);
    // await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    print(response);
    if (mounted) {
      if (response['success'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message']}')),
        );
        return;
      } else {
        await Provider.of<AuthProvider>(context, listen: false).fetchAndSetDispenserId();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device registered!')),
        );
      }
      // Optionally navigate to dashboard or another screen
      // Navigator.of(context).pushReplacementNamed('/dashboard');
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Register Device",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Enter your device ID to link your dispenser.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _deviceIdController,
                    decoration: InputDecoration(
                      labelText: 'Device ID',
                      labelStyle: GoogleFonts.openSans(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      hintText: 'Enter device ID',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(64),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a device ID.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    Center(child: const CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shadowColor: Colors.transparent,
                        backgroundColor: const Color.fromARGB(
                          255,
                          239,
                          255,
                          61,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Register Device',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
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
}
