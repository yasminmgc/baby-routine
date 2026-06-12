import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/baby_controller.dart';

class CreateBabyScreen extends ConsumerStatefulWidget {
  const CreateBabyScreen({super.key});

  @override
  ConsumerState<CreateBabyScreen> createState() => _CreateBabyScreenState();
}

class _CreateBabyScreenState extends ConsumerState<CreateBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();

  DateTime _birthDate = DateTime.now();
  String? _gender;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _createBaby() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final weight = _weightController.text.trim();
    final height = _heightController.text.trim();
    final allergies = _allergiesController.text.trim();

    await ref.read(babyControllerProvider.notifier).createBaby(
          name: name,
          birthDate: _birthDate,
          gender: _gender,
          initialWeightKg: weight.isNotEmpty ? double.tryParse(weight) : null,
          initialHeightCm: height.isNotEmpty ? double.tryParse(height) : null,
          allergies: allergies.isNotEmpty ? allergies : null,
        );

    if (!mounted) return;

    final state = ref.read(babyControllerProvider);
    if (state.hasError) {
      final message = _extractError(state.error!);
      AppSnackbar.showError(context, message);
    } else if (state.hasValue) {
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
    final state = ref.watch(babyControllerProvider);
    final isLoading = state is AsyncLoading;
    final dateFormatted = DateFormat('dd/MM/yyyy', 'pt_BR').format(_birthDate);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Cadastrar bebê'),
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
              // Name
              AppTextField(
                label: 'Nome',
                hintText: 'Nome do bebê',
                controller: _nameController,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),

              // Birth date
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data de nascimento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    suffixIcon:
                        const Icon(Icons.calendar_today, color: AppColors.lilacDark),
                  ),
                  child: Text(
                    dateFormatted,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  hintText: 'Selecione o sexo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Masculino')),
                  DropdownMenuItem(value: 'female', child: Text('Feminino')),
                ],
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 16),

              // Weight and Height — side by side
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Peso (kg)',
                      hintText: 'Ex: 3.5',
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Altura (cm)',
                      hintText: 'Ex: 50',
                      controller: _heightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Allergies
              AppTextField(
                label: 'Alergias',
                hintText: 'Ex: lactose, amendoim...',
                controller: _allergiesController,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Submit button
              AppButton(
                label: 'Cadastrar',
                isLoading: isLoading,
                onPressed: isLoading ? null : _createBaby,
              ),
              const SizedBox(height: 16),

              // Cancel button
              OutlinedButton(
                onPressed: () => context.go('/babies'),
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
