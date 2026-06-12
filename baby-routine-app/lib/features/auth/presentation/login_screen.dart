import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authControllerProvider.notifier).login(email, password);

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      final message = _extractError(authState.error!);
      AppSnackbar.showError(context, message);
    } else if (authState.hasValue) {
      context.go('/babies');
    }
  }

  String _extractError(Object error) {
    // DioException carries the API error response.
    // DioException is imported transitively; typed check works at runtime.
    if (error is dynamic && error.toString().contains('DioException')) {
      try {
        // Try to extract { message } from Dio's error response
        final dioError = error as dynamic;
        final data = dioError.response?.data;
        if (data != null && data is Map && data.containsKey('message')) {
          return data['message'] as String;
        }
        final statusMessage = dioError.message?.toString() ?? '';
        if (statusMessage.isNotEmpty) return statusMessage;
      } catch (_) {}
    }
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // App icon and title
                Icon(
                  Icons.child_care,
                  size: 64,
                  color: AppColors.lilacDark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Baby Routine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lilacDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 48),
                // Email field
                AppTextField(
                  label: 'E-mail',
                  hintText: 'Seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                // Password field
                AppTextField(
                  label: 'Senha',
                  hintText: 'Sua senha',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textGray,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Login button
                AppButton(
                  label: 'Entrar',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _login,
                ),
                const SizedBox(height: 24),
                // Link to register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta? ',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppColors.lilacDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
