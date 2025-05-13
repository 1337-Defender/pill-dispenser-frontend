import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AuthSettingsPopover extends StatelessWidget {
  const AuthSettingsPopover({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await authProvider.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          child: Container(
            height: 50,
            color: Colors.white,
            child: Center(
              child: Text(
                "Logout",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        )
      ],
    );
  }
}