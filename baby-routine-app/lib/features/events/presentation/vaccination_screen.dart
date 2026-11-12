import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/event_controller.dart';

class VaccinationScreen extends ConsumerStatefulWidget {
  const VaccinationScreen({super.key});

  @override
  ConsumerState<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends ConsumerState<VaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _lotController = TextEditingController();
  String _site = 'left_thigh';
  final _appliedByController = TextEditingController();
  final _reactionsController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _occurredAt = DateTime.now();

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _lotController.dispose();
    _appliedByController.dispose();
    _reactionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _siteLabel(String site) {
    switch (site) {
      case 'left_thigh':
        return 'Coxa esquerda';
      case 'right_thigh':
        return 'Coxa direita';
      case 'left_arm':
        return 'Braço esquerdo';
      case 'right_arm':
        return 'Braço direito';
      default:
        return site;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vaccineNameText = _vaccineNameController.text.trim();
    if (vaccineNameText.isEmpty) {
      AppSnackbar.showError(context, 'Informe o nome da vacina');
      return;
    }

    final notesText = _notesController.text.trim();
    final reactionsText = _reactionsController.text.trim();

    final details = <String, dynamic>{
      'vaccineName': vaccineNameText,
      'site': _site,
      if (_lotController.text.trim().isNotEmpty)
        'lot': _lotController.text.trim(),
      if (_appliedByController.text.trim().isNotEmpty)
        'appliedBy': _appliedByController.text.trim(),
      if (reactionsText.isNotEmpty) 'reactions': reactionsText,
    };

    try {
      await ref.read(eventControllerProvider.notifier).createEvent(
            eventType: 'vaccination',
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
      AppSnackbar.showSuccess(context, 'Vacina registrada com sucesso!');
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
        title: const Text('Registrar Vacina'),
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
              // Vaccine name
              AppTextField(
                label: 'Nome da vacina',
                hintText: 'Ex: Pentavalente, Meningocócica B',
                controller: _vaccineNameController,
              ),
              const SizedBox(height: 16),

              // Lot number
              AppTextField(
                label: 'Lote',
                hintText: 'Ex: 2025A-001',
                controller: _lotController,
              ),
              const SizedBox(height: 16),

              // Application site dropdown
              DropdownButtonFormField<String>(
                value: _site,
                decoration: InputDecoration(
                  labelText: 'Local de aplicação',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'left_thigh', child: Text('Coxa esquerda')),
                  DropdownMenuItem(
                      value: 'right_thigh', child: Text('Coxa direita')),
                  DropdownMenuItem(
                      value: 'left_arm', child: Text('Braço esquerdo')),
                  DropdownMenuItem(
                      value: 'right_arm', child: Text('Braço direito')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _site = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Applied by
              AppTextField(
                label: 'Aplicado por',
                hintText: 'Ex: Enf. Maria Santos',
                controller: _appliedByController,
              ),
              const SizedBox(height: 16),

              // Reactions
              AppTextField(
                label: 'Reações',
                hintText: 'Ex: Febre leve, inchaço no local',
                controller: _reactionsController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'Observações',
                hintText: 'Ex: Próxima dose em 2 meses',
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
