// ==========================================
// EXAM STUDY GUIDE: MOBILE APP DEVELOPMENT
// ==========================================
// This file contains simplified versions of the core logic and screens
// from your EduTrack Flutter application to help you study for your exam.
// Your teacher might ask about validation, state management, or UI building.

import 'package:flutter/material.dart';

// ------------------------------------------
// 1. MODELS & ENUMS (Data Structure)
// ------------------------------------------

// Enum: Used to define a fixed set of constant values (like Gender)
enum Gender { male, female, preferNotToSay }

// Model Class: Used to represent data in your application
class UserModel {
  final String fullName;
  final String email;
  final String password;
  final Gender gender;

  // Constructor
  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.gender,
  });
}


// ------------------------------------------
// 2. VALIDATORS (Logic for Email, Password, etc.)
// ------------------------------------------
// This class contains static methods to check if user input is correct.
class AppValidators {
  
  // 1. Check if a field is empty
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null; // Return null if validation passes
  }

  // 2. Validate Email using Regular Expressions (Regex)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    // Regex for basic email format: something@something.domain
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // 3. Validate Password (min 6 chars, 1 uppercase, 1 special char)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain at least 1 uppercase letter.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;]').hasMatch(value)) {
      return 'Must contain at least 1 special character.';
    }
    return null;
  }
}


// ------------------------------------------
// 3. AUTHENTICATION LOGIC (Login & Register)
// ------------------------------------------
// This represents your AuthController using ChangeNotifier for State Management.
class AuthLogic extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Mocking what SharedPreferences does in your real app
  String storedEmail = "student@email.com";
  String storedPassword = "Password123!";

  // Login Logic
  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners(); // Tells the UI to rebuild (show loading spinner)
    
    // Simulate waiting for a network request or database read
    await Future.delayed(const Duration(seconds: 1));

    // Check if the provided credentials match the stored ones
    if (email.trim() == storedEmail && password == storedPassword) {
      isLoading = false;
      notifyListeners();
      return true; // Login success
    } else {
      errorMessage = 'Invalid email or password.';
      isLoading = false;
      notifyListeners();
      return false; // Login failed
    }
  }

  // Register Logic
  Future<bool> register(UserModel user) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Save to database (in real app, this is SharedPreferences)
    storedEmail = user.email;
    storedPassword = user.password;
    
    isLoading = false;
    notifyListeners();
    return true; // Registration success
  }
}


// ------------------------------------------
// 4. LOGIN SCREEN (UI & Form Handling)
// ------------------------------------------
// StatefulWidget is used because the form inputs change over time.
class SimplifiedLoginScreen extends StatefulWidget {
  @override
  _SimplifiedLoginScreenState createState() => _SimplifiedLoginScreenState();
}

class _SimplifiedLoginScreenState extends State<SimplifiedLoginScreen> {
  // GlobalKey is required to identify the Form and validate it
  final _formKey = GlobalKey<FormState>();
  
  // Controllers read the text typed into the TextFields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Function called when Login button is pressed
  void _handleLogin() {
    // 1. Validate the form using the validators assigned to TextFields
    if (_formKey.currentState!.validate()) {
      
      // 2. If valid, proceed with login logic
      String email = _emailController.text;
      String password = _passwordController.text;
      
      print("Attempting to login with Email: $email");
      // Here you would call your AuthController's login method
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Form(
        key: _formKey, // Attach the form key
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Email Text Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email Address"),
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.email, // Calls our email validator logic
              ),
              
              const SizedBox(height: 16),
              
              // Password Text Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true, // Hides the text (shows dots)
                validator: AppValidators.requiredField,
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text("Sign In"),
              )
            ],
          ),
        ),
      ),
    );
  }
}


// ------------------------------------------
// 5. REGISTRATION SCREEN (UI)
// ------------------------------------------
class SimplifiedRegistrationScreen extends StatefulWidget {
  @override
  _SimplifiedRegistrationScreenState createState() => _SimplifiedRegistrationScreenState();
}

class _SimplifiedRegistrationScreenState extends State<SimplifiedRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      print("Form is valid! Proceeding to register...");
      // Create user model and call auth controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: AppValidators.requiredField,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: AppValidators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: AppValidators.password, // Uses our strict password rule
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleRegister,
                child: const Text("Register"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
