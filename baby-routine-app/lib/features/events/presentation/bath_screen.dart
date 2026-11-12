import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/event_controller.dart';

class BathScreen extends ConsumerStatefulWidget {
  const BathScreen({super.key});

  @override
  ConsumerState<BathScreen> createState() => _BathScreenState();
}

class _BathScreenState extends ConsumerState<BathScreen> {
  final _formKey = GlobalKey<FormState>();
  String _temperature = 'warm';
  final _notesController = TextEditingController();
  DateTime _occurredAt = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notesText = _notesController.text.trim();

    final details = <String, dynamic>{
      'temperature': _temperature,
    };

    try {
      await ref.read(eventControllerProvider.notifier).createEvent(
            eventType: 'bath',
            occurredAt: _occurredAt,
            details: details,
            notes: notesText.isNotEmpty ? notesText : null,
          );
    } catch (_) {
      // Error handled via controller state
    }

    if (!mounted) return;

    final state = ref.read(eventControllerProvider);
    if (state.hasError) {
      final message = _extractError(state.error!);
      AppSnackbar.showError(context, message);
    } else if (state.hasValue) {
      AppSnackbar.showSuccess(context, 'Banho registrado com sucesso!');
      context.go('/home');
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
    final state = ref.watch(eventControllerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Registrar Banho'),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Temperature dropdown
              DropdownButtonFormField<String>(
                value: _temperature,
                decoration: InputDecoration(
                  labelText: 'Temperatura da água',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
                items: const [
                  DropdownMenuItem(value: 'warm', child: Text('Morna')),
                  DropdownMenuItem(value: 'hot', child: Text('Quente')),
                  DropdownMenuItem(value: 'cold', child: Text('Fria')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _temperature = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'Observações',
                hintText: 'Ex: Gostou bastante, brincou na água',
                controller: _notesController,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Submit button
              AppButton(
                label: 'Registrar',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),

              // Cancel button
              OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGray,
                  side: const BorderSide(color: AppColors.textGray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
