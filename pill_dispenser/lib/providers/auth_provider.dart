// lib/providers/auth_provider.dart

// import 'package:flutter/material.dart';

// class AuthProvider with ChangeNotifier {
//   bool _isLoggedIn = false;
//   String _userId = '';

//   bool get isLoggedIn => _isLoggedIn;
//   String get userId => _userId;

//   void login(String id) {
//     _isLoggedIn = true;
//     _userId = id;
//     notifyListeners();
//   }

//   void logout() {
//     _isLoggedIn = false;
//     _userId = '';
//     notifyListeners();
//   }
// }

// features/auth/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, authenticating, error }

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  User? _currentUser;
  AuthStatus _authStatus = AuthStatus.unknown;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authStateSubscription;

  User? get currentUser => _currentUser;
  AuthStatus get authStatus => _authStatus;
  String? get errorMessage => _errorMessage;

  String? _dispenserId;
  String? get dispenserId => _dispenserId;

  AuthProvider() {
    _authStatus = AuthStatus.unknown;
    notifyListeners();

    // Listen to auth state changes
    _authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        _currentUser = session.user;
        _authStatus = AuthStatus.authenticated;
        _errorMessage = null;
      } else {
        _currentUser = null;
        _authStatus = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });

    // Check initial session
    _recoverSession();
  }

  Future<void> _recoverSession() async {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
        _currentUser = session.user;
        _authStatus = AuthStatus.authenticated;
        await fetchAndSetDispenserId();
    } else {
        _authStatus = AuthStatus.unauthenticated;
        _dispenserId = null;
    }
    notifyListeners();
  }

  Future<void> fetchAndSetDispenserId() async {
    if (_currentUser == null) {
      _dispenserId = null;
      notifyListeners();
      return;
    }
    try {
      final result = await _supabaseClient
          .from('dispensers')
          .select('id')
          .eq('user_id', _currentUser!.id)
          .maybeSingle();
      print(result);
      _dispenserId = result?['id'] as String?;
      notifyListeners();
    } catch (e) {
      print("ERRORRRRR: $e");
      _dispenserId = null;
      notifyListeners();
    }
  }


  Future<bool> signUp(String email, String password) async {
    _authStatus = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _currentUser = response.user;
        // Note: Supabase sends a confirmation email by default.
        // For this flow, we assume auto-confirmation or immediate login.
        // If email confirmation is on, the user won't be authenticated until confirmed.
        // You might need to adjust based on your Supabase project's auth settings.
        _authStatus = response.session != null ? AuthStatus.authenticated : AuthStatus.unauthenticated; // Or a new 'needsConfirmation' status
        notifyListeners();
        return true; // Successful sign-up (might need email confirmation)
      } else {
        _errorMessage = "Sign up failed: No user data returned.";
        _authStatus = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = "Sign up error: ${e.message}";
      _authStatus = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred: $e";
      _authStatus = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _authStatus = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _currentUser = response.user;
        _authStatus = AuthStatus.authenticated;
        await fetchAndSetDispenserId();
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Sign in failed: No user data returned.";
         _authStatus = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = "Sign in error: ${e.message}";
      _authStatus = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred: $e";
      _authStatus = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    _currentUser = null;
    _authStatus = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // Method to register a dispenser
  Future<String?> registerDispenser(String hardwareId) async {
    if (_currentUser == null) {
      return "User not authenticated.";
    }
    _authStatus = AuthStatus.authenticating; // Or a custom 'registeringDevice' status
    notifyListeners();

    try {
      // Check if dispenser with this hardware_id already exists and is claimed
      final existingDispenserCheck = await _supabaseClient
          .from('dispensers')
          .select('id, user_id')
          .eq('id', hardwareId)
          .maybeSingle(); // Use .maybeSingle() if it can be null

      if (existingDispenserCheck != null && existingDispenserCheck['user_id'] != null && existingDispenserCheck['user_id'] != _currentUser!.id) {
          _authStatus = AuthStatus.authenticated; // Back to normal auth status
          notifyListeners();
          return "Device ID already registered by another user.";
      }
      if (existingDispenserCheck != null && existingDispenserCheck['user_id'] == _currentUser!.id) {
          _authStatus = AuthStatus.authenticated;
          notifyListeners();
          return null; // Already registered to this user, success.
      }
      // If it exists and user_id is null, or doesn't exist, proceed to insert/update
      // For simplicity, we'll attempt an upsert or a direct insert here.
      // A more robust flow might separate checking and then inserting/updating.

      final response = await _supabaseClient.from('dispenser_schema.dispensers').upsert({
        'hardware_id': hardwareId,
        'user_id': _currentUser!.id,
        // You might want to default other fields or update them if the row exists
        // If 'hardware_id' is the unique key, upsert works well.
        // If your primary key is 'id' (UUID) and 'hardware_id' is just unique,
        // you'd do a select then insert/update.
        // For this example, assuming hardware_id can be used with upsert logic
        // or we create a new one.
        // This simplified version creates a new one, ensure RLS allows this.
        // If you want to claim an existing one, you'd query for hardware_id, get its UUID id, then update.
      },
      // onConflict: 'hardware_id', // If you want to update if hardware_id exists
      ).select(); // Select to get the data back

      // The .upsert might behave differently based on your table constraints.
      // A safer direct insert if hardware_id is globally unique and dispenser is new to any user:
      // final response = await _supabaseClient.from('dispensers').insert({
      //   'hardware_id': hardwareId,
      //   'user_id': _currentUser!.id,
      //   'name': 'My New Dispenser', // Default name
      //   'timezone': 'UTC', // Default timezone
      //   'status': 'online' // Initial status
      // }).select();

      if (response.isEmpty) { // Or check for error in response
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
        return "Failed to register device. Please try again.";
      }

      _authStatus = AuthStatus.authenticated;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _authStatus = AuthStatus.authenticated;
      notifyListeners();
      return "Error registering device: ${e.toString()}";
    }
  }


  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}