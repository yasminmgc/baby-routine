import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/event_controller.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _professionalController = TextEditingController();
  final _specialtyController = TextEditingController();
  String _appointmentType = 'routine';
  final _recommendationsController = TextEditingController();
  final _requestedExams = <String>[];
  final _examController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _occurredAt = DateTime.now();

  @override
  void dispose() {
    _professionalController.dispose();
    _specialtyController.dispose();
    _recommendationsController.dispose();
    _examController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addExam() {
    final exam = _examController.text.trim();
    if (exam.isNotEmpty && !_requestedExams.contains(exam)) {
      setState(() {
        _requestedExams.add(exam);
        _examController.clear();
      });
    }
  }

  void _removeExam(int index) {
    setState(() {
      _requestedExams.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final professionalText = _professionalController.text.trim();
    if (professionalText.isEmpty) {
      AppSnackbar.showError(context, 'Informe o nome do profissional');
      return;
    }

    final notesText = _notesController.text.trim();
    final recommendationsText = _recommendationsController.text.trim();

    final details = <String, dynamic>{
      'professionalName': professionalText,
      'specialty': _specialtyController.text.trim().isNotEmpty
          ? _specialtyController.text.trim()
          : null,
      'appointmentType': _appointmentType,
      if (recommendationsText.isNotEmpty)
        'recommendations': recommendationsText,
      'requestedExams': _requestedExams,
    };

    try {
      await ref.read(eventControllerProvider.notifier).createEvent(
            eventType: 'appointment',
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
      AppSnackbar.showSuccess(context, 'Consulta registrada com sucesso!');
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
        title: const Text('Registrar Consulta'),
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
              // Professional name
              AppTextField(
                label: 'Nome do profissional',
                hintText: 'Ex: Dr. João Silva',
                controller: _professionalController,
              ),
              const SizedBox(height: 16),

              // Specialty
              AppTextField(
                label: 'Especialidade',
                hintText: 'Ex: Pediatra, Oftalmologista',
                controller: _specialtyController,
              ),
              const SizedBox(height: 16),

              // Appointment type dropdown
              DropdownButtonFormField<String>(
                value: _appointmentType,
                decoration: InputDecoration(
                  labelText: 'Tipo de consulta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
                items: const [
                  DropdownMenuItem(value: 'routine', child: Text('Rotina')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _appointmentType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Recommendations
              AppTextField(
                label: 'Recomendações',
                hintText: 'Ex: Fazer exercícios diários',
                controller: _recommendationsController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Requested exams
              const Text(
                'Exames solicitados',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 8),

              // Exam list
              if (_requestedExams.isNotEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _requestedExams.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final exam = entry.value;
                      return Chip(
                        label: Text(exam),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeExam(idx),
                        backgroundColor: AppColors.lavender.withOpacity(0.4),
                        labelStyle: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 8),

              // Add exam row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Novo exame',
                      hintText: 'Ex: Hemograma',
                      controller: _examController,
                      onSubmitted: (_) => _addExam(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addExam,
                    icon: const Icon(Icons.add_circle, size: 32),
                    color: AppColors.lilacDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'Observações',
                hintText: 'Ex: Retorno em 3 meses',
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
