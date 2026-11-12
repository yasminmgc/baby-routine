import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/event_controller.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _doseController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _occurredAt = DateTime.now();

  @override
  void dispose() {
    _medicationNameController.dispose();
    _doseController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final medicationNameText = _medicationNameController.text.trim();
    if (medicationNameText.isEmpty) {
      AppSnackbar.showError(context, 'Informe o nome do medicamento');
      return;
    }

    final notesText = _notesController.text.trim();
    final doseText = _doseController.text.trim();
    final reasonText = _reasonController.text.trim();

    final details = <String, dynamic>{
      'medicationName': medicationNameText,
      if (doseText.isNotEmpty) 'dose': doseText,
      if (reasonText.isNotEmpty) 'reason': reasonText,
    };

    try {
      await ref.read(eventControllerProvider.notifier).createEvent(
            eventType: 'medication',
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
      AppSnackbar.showSuccess(context, 'Medicação registrada com sucesso!');
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
        title: const Text('Registrar Medicação'),
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
              // Medication name
              AppTextField(
                label: 'Nome do medicamento',
                hintText: 'Ex: Paracetamol, Dipirona',
                controller: _medicationNameController,
              ),
              const SizedBox(height: 16),

              // Dose
              AppTextField(
                label: 'Dose',
                hintText: 'Ex: 5ml, 10 gotas',
                controller: _doseController,
              ),
              const SizedBox(height: 16),

              // Reason
              AppTextField(
                label: 'Motivo',
                hintText: 'Ex: Febre de 38°C',
                controller: _reasonController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'Observações',
                hintText: 'Ex: Dar a cada 6h por 3 dias',
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
