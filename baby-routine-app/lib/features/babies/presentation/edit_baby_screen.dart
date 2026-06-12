import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/baby_controller.dart';
import '../models/baby.dart';

class EditBabyScreen extends ConsumerStatefulWidget {
  const EditBabyScreen({super.key});

  @override
  ConsumerState<EditBabyScreen> createState() => _EditBabyScreenState();
}

class _EditBabyScreenState extends ConsumerState<EditBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();

  late DateTime _birthDate;
  String? _gender;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  Baby? get _baby => ref.read(selectedBabyProvider);

  @override
  void initState() {
    super.initState();
    final baby = _baby;
    if (baby != null) {
      _nameController.text = baby.name;
      _birthDate = baby.birthDate;
      _gender = baby.gender;
      if (baby.initialWeightKg != null) {
        _weightController.text = baby.initialWeightKg.toString();
      }
      if (baby.initialHeightCm != null) {
        _heightController.text = baby.initialHeightCm.toString();
      }
      _allergiesController.text = baby.allergies ?? '';
    }
  }

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

  Future<void> _updateBaby() async {
    if (!_formKey.currentState!.validate()) return;

    final baby = _baby;
    if (baby == null) return;

    final name = _nameController.text.trim();
    final weight = _weightController.text.trim();
    final height = _heightController.text.trim();
    final allergies = _allergiesController.text.trim();

    await ref.read(babyControllerProvider.notifier).updateBaby(
          baby.id,
          name: name,
          birthDate: _birthDate,
          gender: _gender,
          initialWeightKg: weight.isNotEmpty ? double.tryParse(weight) : null,
          initialHeightCm:
              height.isNotEmpty ? double.tryParse(height) : null,
          allergies: allergies.isNotEmpty ? allergies : null,
        );

    if (!mounted) return;

    final state = ref.read(babyControllerProvider);
    if (state.hasError) {
      final message = _extractError(state.error!);
      AppSnackbar.showError(context, message);
    } else if (state.hasValue) {
      AppSnackbar.showSuccess(context, 'Bebê atualizado com sucesso');
      context.go('/home');
    }
  }

  Future<void> _deleteBaby() async {
    final baby = _baby;
    if (baby == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir bebê'),
        content: const Text(
          'Tem certeza que deseja excluir este bebê? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(babyControllerProvider.notifier).deleteBaby(baby.id);

    if (!mounted) return;

    final state = ref.read(babyControllerProvider);
    if (state.hasError) {
      final message = _extractError(state.error!);
      AppSnackbar.showError(context, message);
    } else if (state.hasValue) {
      AppSnackbar.showSuccess(context, 'Bebê excluído');
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
    final baby = _baby;
    if (baby == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar bebê'),
          backgroundColor: AppColors.lilacDark,
          foregroundColor: AppColors.white,
        ),
        body: const Center(
          child: Text('Nenhum bebê selecionado'),
        ),
      );
    }

    final state = ref.watch(babyControllerProvider);
    final isLoading = state is AsyncLoading;
    final isOwner = baby.currentUserRole == 'owner';
    final dateFormatted =
        DateFormat('dd/MM/yyyy', 'pt_BR').format(_birthDate);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Editar bebê'),
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
                    suffixIcon: const Icon(Icons.calendar_today,
                        color: AppColors.lilacDark),
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

              // Weight and Height
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Peso (kg)',
                      hintText: 'Ex: 3.5',
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Altura (cm)',
                      hintText: 'Ex: 50',
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
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

              // Update button
              AppButton(
                label: 'Salvar alterações',
                isLoading: isLoading,
                onPressed: isLoading ? null : _updateBaby,
              ),
              const SizedBox(height: 12),

              // Delete button — only visible to owner
              if (isOwner)
                AppButton(
                  label: 'Excluir bebê',
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  onPressed: isLoading ? null : _deleteBaby,
                ),
              const SizedBox(height: 12),

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
