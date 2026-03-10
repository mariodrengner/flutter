import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:habit_flow/features/auth/state/auth/auth_provider.dart';
import 'package:habit_flow/features/auth/state/login/login_controller.dart';
import 'package:habit_flow/features/auth/state/login/login_obscure_provider.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_error_banner.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_footer_links.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_header.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_primary_button.dart';
import 'package:habit_flow/features/auth/ui/widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(loginControllerProvider.notifier)
          .submit(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final obscurePassword = ref.watch(loginObscureProvider);

    final errorMessage = loginState.whenOrNull(error: (e, _) => e.toString());
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
                    icon: Icons.check_circle_outline,
                    title: 'Willkommen zurück',
                    subtitle: 'Melde dich an, um fortzufahren',
                  ),
                  AuthErrorBanner(message: errorMessage),
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
                        ref.read(loginObscureProvider.notifier).toggle();
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
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Anmelden',
                    isLoading: loginState.isLoading,
                    onPressed: _handleLogin,
                  ),
                  AuthFooterLinks(
                    promptText: 'Noch kein Konto? ',
                    actionText: 'Registrieren',
                    onActionPressed: () => context.go(AppRoutes.register),
                    secondaryActionText: 'Als Gast fortfahren',
                    onSecondaryActionPressed: () async {
                      await ref.read(authProvider.notifier).createGuestUser();
                      if (context.mounted) context.go(AppRoutes.home);
                    },
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
