import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../controllers/baby_controller.dart';
import '../models/baby.dart';
import '../repositories/baby_repository.dart';

class CaregiversScreen extends ConsumerStatefulWidget {
  const CaregiversScreen({super.key});

  @override
  ConsumerState<CaregiversScreen> createState() => _CaregiversScreenState();
}

class _CaregiversScreenState extends ConsumerState<CaregiversScreen> {
  List<Caregiver>? _caregivers;
  bool _isLoading = true;
  String? _error;

  Baby? get _baby => ref.read(selectedBabyProvider);

  @override
  void initState() {
    super.initState();
    _loadCaregivers();
  }

  Future<void> _loadCaregivers() async {
    final baby = _baby;
    if (baby == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repository = ref.read(babyRepositoryProvider);
      final caregivers = await repository.listCaregivers(baby.id);
      if (!mounted) return;
      setState(() {
        _caregivers = caregivers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _extractError(e);
      });
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

  Future<void> _showAddCaregiverDialog() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar cuidador'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'E-mail do cuidador',
              hintText: 'exemplo@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.lightGray,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'E-mail é obrigatório';
              }
              final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, emailController.text.trim());
              }
            },
            child: Text(
              'Adicionar',
              style: TextStyle(color: AppColors.lilacDark),
            ),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    final baby = _baby;
    if (baby == null) return;

    await ref
        .read(babyControllerProvider.notifier)
        .addCaregiver(baby.id, email);

    if (!mounted) return;

    final state = ref.read(babyControllerProvider);
    if (state.hasError) {
      final message = _extractError(state.error!);
      AppSnackbar.showError(context, message);
    } else if (state.hasValue) {
      AppSnackbar.showSuccess(context, 'Cuidador adicionado');
      _loadCaregivers();
    }
  }

  Future<void> _removeCaregiver(Caregiver caregiver) async {
    final baby = _baby;
    if (baby == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover cuidador'),
        content: Text(
          'Remover ${caregiver.name} dos cuidadores?',
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
              'Remover',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(babyControllerProvider.notifier)
        .removeCaregiver(baby.id, caregiver.id);

    if (!mounted) return;

    final state = ref.read(babyControllerProvider);
    if (state.hasError) {
      final message = _extractError(state.error!);
      AppSnackbar.showError(context, message);
    } else if (state.hasValue) {
      AppSnackbar.showSuccess(context, 'Cuidador removido');
      _loadCaregivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baby = _baby;
    final isOwner = baby?.currentUserRole == 'owner';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Cuidadores'),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
      ),
      body: _buildBody(),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              backgroundColor: AppColors.lilacDark,
              foregroundColor: AppColors.white,
              onPressed: _showAddCaregiverDialog,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoading(message: 'Carregando cuidadores...');
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loadCaregivers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lilacDark,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tentar novamente',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_caregivers == null || _caregivers!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.lilac),
            const SizedBox(height: 16),
            const Text(
              'Nenhum cuidador',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _baby?.currentUserRole == 'owner'
                  ? 'Adicione cuidadores para compartilhar a rotina'
                  : 'Apenas o responsável pode adicionar cuidadores',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      );
    }

    final baby = _baby;
    final isOwner = baby?.currentUserRole == 'owner';

    return RefreshIndicator(
      onRefresh: _loadCaregivers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _caregivers!.length,
        itemBuilder: (context, index) {
          final caregiver = _caregivers![index];
          final isCaregiverOwner = caregiver.role == 'owner';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isCaregiverOwner
                    ? AppColors.lilacDark
                    : AppColors.mint,
                child: Icon(
                  isCaregiverOwner ? Icons.star : Icons.person,
                  color: AppColors.white,
                ),
              ),
              title: Text(
                caregiver.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Text(
                caregiver.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCaregiverOwner
                          ? AppColors.lilacDark.withOpacity(0.1)
                          : AppColors.mint.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCaregiverOwner ? 'Responsável' : 'Cuidador(a)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCaregiverOwner
                            ? AppColors.lilacDark
                            : AppColors.mint,
                      ),
                    ),
                  ),
                  if (isOwner && !isCaregiverOwner) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon:
                          Icon(Icons.remove_circle, color: AppColors.error),
                      onPressed: () => _removeCaregiver(caregiver),
                      tooltip: 'Remover cuidador',
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
