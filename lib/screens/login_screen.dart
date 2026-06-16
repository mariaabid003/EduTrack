// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../validators/app_validators.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await controller.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Login failed.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      controller.resetState();
    }
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
                  children: [
                    const AppGradientHeader(
                      title: 'Welcome Back',
                      subtitle: 'Sign in to continue your journey',
                      icon: Icons.waving_hand_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Email
                            AppTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: AppValidators.loginEmail,
                            ),
                            const SizedBox(height: 14),

                            // Password
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscureText: !controller.loginPasswordVisible,
                              textInputAction: TextInputAction.done,
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.loginPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMedium,
                                ),
                                onPressed:
                                    controller.toggleLoginPasswordVisibility,
                              ),
                              validator: AppValidators.loginPassword,
                              onFieldSubmitted: (_) {
                                if (!isLoading) _handleLogin(controller);
                              },
                            ),

                            const SizedBox(height: 12),

                            // Remember Me
                            Row(
                              children: [
                                Checkbox(
                                  value: controller.rememberMe,
                                  onChanged: (v) =>
                                      controller.setRememberMe(v ?? false),
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: AppTheme.textMedium,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Login Button
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleLogin(controller),
                              child: const Text('Sign In'),
                            ),

                            const SizedBox(height: 20),

                            // Divider
                            const Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: AppTheme.divider, thickness: 1)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: AppTheme.divider, thickness: 1)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Register Button
                            OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const RegistrationScreen()),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: const BorderSide(
                                    color: AppTheme.primary, width: 1.5),
                                foregroundColor: AppTheme.primary,
                              ),
                              child: const Text(
                                'Create New Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
}
