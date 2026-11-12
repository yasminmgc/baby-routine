import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/event_controller.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _location = 'crib';
  final _notesController = TextEditingController();
  DateTime _occurredAt = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int? _calculateDuration() {
    if (_startTime == null || _endTime == null) return null;
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }
    return endDateTime.difference(startDateTime).inMinutes;
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _timeLabel(TimeOfDay? time) {
    if (time == null) return 'Selecionar';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null) {
      AppSnackbar.showError(context, 'Selecione o horário de início');
      return;
    }
    if (_endTime == null) {
      AppSnackbar.showError(context, 'Selecione o horário de término');
      return;
    }

    final notesText = _notesController.text.trim();
    final duration = _calculateDuration();

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year, now.month, now.day,
      _startTime!.hour, _startTime!.minute,
    );
    final endDateTime = DateTime(
      now.year, now.month, now.day,
      _endTime!.hour, _endTime!.minute,
    );

    final details = <String, dynamic>{
      'startTime': startDateTime.toIso8601String(),
      'endTime': endDateTime.toIso8601String(),
      if (duration != null) 'durationMin': duration,
      'location': _location,
    };

    try {
      await ref.read(eventControllerProvider.notifier).createEvent(
            eventType: 'sleep',
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
      AppSnackbar.showSuccess(context, 'Sono registrado com sucesso!');
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
    final duration = _calculateDuration();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Registrar Sono'),
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
              // Start time
              InkWell(
                onTap: () => _pickTime(true),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hora de início',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    suffixIcon: const Icon(
                      Icons.access_time,
                      color: AppColors.lilacDark,
                    ),
                  ),
                  child: Text(
                    _timeLabel(_startTime),
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _startTime != null ? AppColors.textDark : AppColors.textGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End time
              InkWell(
                onTap: () => _pickTime(false),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hora de término',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    suffixIcon: const Icon(
                      Icons.access_time,
                      color: AppColors.lilacDark,
                    ),
                  ),
                  child: Text(
                    _timeLabel(_endTime),
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _endTime != null ? AppColors.textDark : AppColors.textGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Duration (auto-calculated)
              if (duration != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: AppColors.lilacDark,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lilacDark,
                        ),
                      ),
                    ],
                  ),
                ),
              if (duration != null) const SizedBox(height: 16),

              // Location dropdown
              DropdownButtonFormField<String>(
                value: _location,
                decoration: InputDecoration(
                  labelText: 'Local',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
                items: const [
                  DropdownMenuItem(value: 'crib', child: Text('Berço')),
                  DropdownMenuItem(value: 'bed', child: Text('Cama')),
                  DropdownMenuItem(value: 'arms', child: Text('Colo')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _location = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'Observações',
                hintText: 'Ex: Dormiu rapidinho',
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

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return 'Duração: ${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return 'Duração: ${hours}h';
    }
    return 'Duração: ${hours}h ${remainingMinutes}min';
  }
}
