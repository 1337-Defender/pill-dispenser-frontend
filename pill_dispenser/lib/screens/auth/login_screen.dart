import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation after actions
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; // Your existing AuthProvider

// Enum to manage which form is visible
enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _currentAuthMode = AuthMode.login;

  final _formKey =
      GlobalKey<
        FormState
      >(); // One key can be used if forms are simple and fields are distinct enough or always rebuilt

  // Login Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Register Controllers
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Invalid form
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    try {
      if (_currentAuthMode == AuthMode.login) {
        success = await authProvider.signIn(
          _loginEmailController.text.trim(),
          _loginPasswordController.text.trim(),
        );
      } else {
        // Register mode
        success = await authProvider.signUp(
          _registerEmailController.text.trim(),
          _registerPasswordController.text.trim(),
        );
      }

      if (mounted && success) {
        if (_currentAuthMode == AuthMode.register) {
          // After successful signup, navigate to device registration
          // Assuming you have a route '/register-device'
          // You might want to clear the form fields as well.
          context.go('/register-device'); // Or your device registration route
        } else {
          // For login, go_router's redirect logic should handle moving to '/dashboard'
          // if AuthProvider updates the auth state correctly.
          // Explicit navigation might not be needed if redirect is robust.
          // context.go('/dashboard'); // This might already be handled by AppRouter redirect
        }
      } else if (mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoginForm({Key? key}) {
    return Column(
      key: key,
      children: <Widget>[
        TextFormField(
          controller: _loginEmailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            hintText: 'Enter your email address',
            filled: true,
            fillColor: Color.fromARGB(255, 248, 248, 248),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(64),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty || !value.contains('@')) {
              return 'Please enter a valid email.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _loginPasswordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            hintText: 'Enter your password',
            filled: true,
            fillColor: Color.fromARGB(255, 248, 248, 248),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(64),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty || value.length < 6) {
              return 'Password must be at least 6 characters long.';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _submitAuthForm,
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              shadowColor: Colors.transparent,
              backgroundColor: Color.fromARGB(255, 239, 255, 61),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Login',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterForm({Key? key}) {
    return Column(
      key: key,
      children: <Widget>[
        TextFormField(
          controller: _registerEmailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            hintText: 'Enter your email address',
            filled: true,
            fillColor: Color.fromARGB(255, 248, 248, 248),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(64),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty || !value.contains('@')) {
              return 'Please enter a valid email.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _registerPasswordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            hintText: 'Enter your password',
            filled: true,
            fillColor: Color.fromARGB(255, 248, 248, 248),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(64),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty || value.length < 6) {
              return 'Password must be at least 6 characters long.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _registerConfirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            hintText: 'Re-enter your password',
            filled: true,
            fillColor: Color.fromARGB(255, 248, 248, 248),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(64),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
          ),
          obscureText: true,
          validator: (value) {
            if (value != _registerPasswordController.text) {
              return 'Passwords do not match!';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _submitAuthForm,
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              shadowColor: Colors.transparent,
              backgroundColor: Color.fromARGB(255, 239, 255, 61),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Register',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Allow scrolling on smaller screens
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header Text
                  Text(
                    "Smart Pill Dispenser",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    _currentAuthMode == AuthMode.login
                        ? "Don't have an account? Register"
                        : "Already have an account? Login",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SegmentedButton<AuthMode>(
                    segments: const <ButtonSegment<AuthMode>>[
                      ButtonSegment<AuthMode>(
                        value: AuthMode.login,
                        label: Text('Login'),
                      ),
                      ButtonSegment<AuthMode>(
                        value: AuthMode.register,
                        label: Text('Register'),
                      ),
                    ],
                    selected: <AuthMode>{_currentAuthMode},
                    onSelectionChanged: (Set<AuthMode> newSelection) {
                      setState(() {
                        _currentAuthMode = newSelection.first;
                        _formKey.currentState?.reset();
                        _isLoading = false;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 248, 248, 248),
                      selectedBackgroundColor: Color.fromARGB(
                        255,
                        239,
                        255,
                        61,
                      ),
                      foregroundColor: Colors.black,
                      selectedForegroundColor: Colors.black,
                      side: BorderSide.none, // No border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Pill shape
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: GoogleFonts.openSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // AnimatedSwitcher can provide a nice transition between forms
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                      // Or use SlideTransition for a sliding effect
                      // return SlideTransition(
                      //   position: Tween<Offset>(
                      //     begin: Offset(
                      //       (_currentAuthMode == AuthMode.login ? 1 : -1), 
                      //       0
                      //     ),
                      //     end: Offset.zero,
                      //   ).animate(animation),
                      //   child: child,
                      // );
                    },
                    child:
                        _currentAuthMode == AuthMode.login
                            ? _buildLoginForm()
                            : _buildRegisterForm(),
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
