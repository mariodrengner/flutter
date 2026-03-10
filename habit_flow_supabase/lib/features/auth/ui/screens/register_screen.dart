import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:habit_flow/features/auth/state/register/register_controller.dart';
import 'package:habit_flow/features/auth/state/register/register_confirm_obscure_provider.dart';
import 'package:habit_flow/features/auth/state/register/register_obscure_provider.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_error_banner.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_footer_links.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_header.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_primary_button.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(registerControllerProvider.notifier)
          .submit(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerControllerProvider);
    final obscurePassword = ref.watch(registerObscureProvider);
    final obscureConfirmPassword = ref.watch(registerConfirmObscureProvider);

    final errorMessage = registerState.whenOrNull(
      error: (e, _) => e.toString(),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    icon: Icons.person_add_outlined,
                    title: 'Konto erstellen',
                    subtitle: 'Registriere dich für Habit Flow',
                  ),
                  AuthErrorBanner(message: errorMessage),
                  AuthTextField(
                    controller: _nameController,
                    labelText: 'Name (optional)',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'E-Mail',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte E-Mail eingeben';
                      }
                      if (!value.contains('@')) {
                        return 'Bitte gültige E-Mail eingeben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passwordController,
                    obscureText: obscurePassword,
                    labelText: 'Passwort',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        ref.read(registerObscureProvider.notifier).toggle();
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte Passwort eingeben';
                      }
                      if (value.length < 6) {
                        return 'Passwort muss mindestens 6 Zeichen haben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    labelText: 'Passwort bestätigen',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        ref
                            .read(registerConfirmObscureProvider.notifier)
                            .toggle();
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte Passwort bestätigen';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwörter stimmen nicht überein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Registrieren',
                    isLoading: registerState.isLoading,
                    onPressed: _handleRegister,
                  ),
                  AuthFooterLinks(
                    promptText: 'Bereits ein Konto? ',
                    actionText: 'Anmelden',
                    onActionPressed: () => context.go(AppRoutes.login),
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
