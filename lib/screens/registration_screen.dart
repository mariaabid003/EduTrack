// lib/screens/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../models/user_model.dart';
import '../validators/app_validators.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: controller.selectedGender!,
    );

    final success = await controller.register(user);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Registration failed.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    controller.resetState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        final isLoading = controller.state == AuthState.loading;

        return Scaffold(
          body: LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppGradientHeader(
                      title: 'Create Account',
                      subtitle: 'Fill in your details to get started',
                      icon: Icons.person_add_alt_1_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Basic Information ──
                            _buildSectionHeader(
                              'Basic Information',
                              Icons.info_outline_rounded,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                              validator: AppValidators.fullName,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: AppValidators.email,
                            ),
                            const SizedBox(height: 14),

                            // Gender Dropdown
                            DropdownButtonFormField<Gender>(
                              value: controller.selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                prefixIcon:
                                    const Icon(Icons.people_alt_outlined),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppTheme.divider, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppTheme.divider, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppTheme.primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppTheme.error, width: 1.5),
                                ),
                              ),
                              hint: const Text('Select gender'),
                              items: Gender.values
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g.displayName),
                                      ))
                                  .toList(),
                              onChanged: controller.setGender,
                              validator: (_) =>
                                  AppValidators.gender(controller.selectedGender?.name),
                            ),

                            const SizedBox(height: 28),

                            // ── Password Security ──
                            _buildSectionHeader(
                              'Password Security',
                              Icons.lock_outline_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildPasswordRequirements(),
                            const SizedBox(height: 14),

                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Min 6 chars, 1 uppercase, 1 special',
                              obscureText: !controller.registerPasswordVisible,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.registerPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMedium,
                                ),
                                onPressed:
                                    controller.toggleRegisterPasswordVisibility,
                              ),
                              validator: AppValidators.password,
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Re-type Password',
                              hint: 'Confirm your password',
                              obscureText:
                                  !controller.registerConfirmPasswordVisible,
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.registerConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMedium,
                                ),
                                onPressed: controller
                                    .toggleRegisterConfirmPasswordVisibility,
                              ),
                              validator: (v) => AppValidators.confirmPassword(
                                  v, _passwordController.text),
                              onFieldSubmitted: (_) {
                                if (!isLoading) _handleRegister(controller);
                              },
                            ),
                            const SizedBox(height: 32),

                            // Register Button
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleRegister(controller),
                              child: const Text('Create Account'),
                            ),

                            const SizedBox(height: 20),

                            // Navigate to Login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: AppTheme.textMedium,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                  ),
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
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
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('Minimum 6 characters'),
          _buildRequirement('At least 1 uppercase letter'),
          _buildRequirement('At least 1 special character (!@#\$%...)'),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
