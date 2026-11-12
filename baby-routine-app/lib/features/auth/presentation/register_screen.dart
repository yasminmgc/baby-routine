import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref
        .read(authControllerProvider.notifier)
        .register(name, email, password);

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
    if (error is dynamic && error.toString().contains('DioException')) {
      try {
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
                const SizedBox(height: 16),
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => context.go('/login'),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Criar conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lilacDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados para começar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 40),
                // Name field
                AppTextField(
                  label: 'Nome',
                  hintText: 'Seu nome completo',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
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
                  hintText: 'Mínimo 8 caracteres, 1 maiúscula, 1 número',
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
                // Register button
                AppButton(
                  label: 'Cadastrar',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _register,
                ),
                const SizedBox(height: 24),
                // Link to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta? ',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Entrar',
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
