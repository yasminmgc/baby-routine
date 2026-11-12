import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/baby.dart';
import '../repositories/baby_repository.dart';
import '../controllers/baby_controller.dart';

class SelectBabyScreen extends ConsumerStatefulWidget {
  const SelectBabyScreen({super.key});

  @override
  ConsumerState<SelectBabyScreen> createState() => _SelectBabyScreenState();
}

class _SelectBabyScreenState extends ConsumerState<SelectBabyScreen> {
  List<Baby>? _babies;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBabies();
  }

  Future<void> _loadBabies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repository = ref.read(babyRepositoryProvider);
      final babies = await repository.list();
      if (!mounted) return;
      setState(() {
        _babies = babies;
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

  void _selectBaby(Baby baby) {
    ref.read(selectedBabyProvider.notifier).state = baby;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Meus bebês'),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
        onPressed: () => context.go('/babies/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoading(message: 'Carregando bebês...');
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
              AppButton(
                label: 'Tentar novamente',
                onPressed: _loadBabies,
              ),
            ],
          ),
        ),
      );
    }

    if (_babies == null || _babies!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.child_care, size: 64, color: AppColors.lilac),
              const SizedBox(height: 16),
              Text(
                'Nenhum bebê cadastrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque no botão + para adicionar seu primeiro bebê',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBabies,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _babies!.length,
        itemBuilder: (context, index) {
          final baby = _babies![index];
          return _buildBabyTile(baby);
        },
      ),
    );
  }

  Widget _buildBabyTile(Baby baby) {
    final isOwner = baby.currentUserRole == 'owner';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.lilac,
          child: Icon(
            baby.gender == 'male' ? Icons.boy : Icons.girl,
            color: AppColors.white,
          ),
        ),
        title: Text(
          baby.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          isOwner ? 'Responsável' : 'Cuidador(a)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGray,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isOwner
                ? AppColors.lilacDark.withOpacity(0.1)
                : AppColors.mint.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isOwner ? 'Responsável' : 'Cuidador(a)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOwner ? AppColors.lilacDark : AppColors.mint,
            ),
          ),
        ),
        onTap: () => _selectBaby(baby),
      ),
    );
  }
}

/// Local AppButton used within this screen for error retry.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lilacDark,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
