import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/checklist_controller.dart';
import '../models/checklist_item.dart';

class ChecklistWidget extends ConsumerStatefulWidget {
  const ChecklistWidget({super.key});

  @override
  ConsumerState<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends ConsumerState<ChecklistWidget> {
  String _dateLabel = '';

  @override
  void initState() {
    super.initState();
    _dateLabel = _formatCurrentDate();
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekDay = DateFormatter.formatWeekday(now);
    final date = DateFormatter.formatDate(now);
    return '${weekDay[0].toUpperCase()}${weekDay.substring(1)}, $date';
  }

  Future<void> _refresh() async {
    await ref.read(checklistControllerProvider.notifier).refresh();
  }

  IconData _eventTypeIcon(String activityType) {
    switch (activityType) {
      case 'feeding':
        return Icons.breakfast_dining;
      case 'sleep':
        return Icons.bedtime;
      case 'diaper':
        return Icons.baby_changing_station;
      case 'bath':
        return Icons.bathtub;
      case 'vaccination':
        return Icons.vaccines;
      case 'appointment':
        return Icons.medical_services;
      case 'medication':
        return Icons.medication;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'missed':
        return AppColors.error;
      default:
        return AppColors.textGray;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'missed':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Concluído';
      case 'pending':
        return 'Pendente';
      case 'missed':
        return 'Não realizado';
      default:
        return status;
    }
  }

  String _activityLabel(String activityType) {
    switch (activityType) {
      case 'feeding':
        return 'Alimentação';
      case 'sleep':
        return 'Sono';
      case 'diaper':
        return 'Fralda';
      case 'bath':
        return 'Banho';
      case 'vaccination':
        return 'Vacina';
      case 'appointment':
        return 'Consulta';
      case 'medication':
        return 'Medicação';
      default:
        return activityType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklistAsync = ref.watch(checklistControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.today, color: AppColors.lilacDark, size: 20),
              const SizedBox(width: 8),
              Text(
                _dateLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        // Checklist items
        Expanded(
          child: checklistAsync.when(
            data: (checklist) {
              if (checklist.items.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist,
                            size: 48, color: AppColors.textGray),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma atividade programada para hoje',
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

              final routineItems = checklist.items
                  .where((item) => item.scheduledTime != null)
                  .toList()
                ..sort((a, b) =>
                    a.scheduledTime!.compareTo(b.scheduledTime!));

              final unscheduledItems = checklist.items
                  .where((item) => item.scheduledTime == null)
                  .toList();

              final sortedItems = [...routineItems, ...unscheduledItems];

              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.lilacDark,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: sortedItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return _buildChecklistItem(item);
                  },
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.lilacDark),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(
                      'Erro ao carregar checklist',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    final statusColor = _statusColor(item.status);

    return Card(
      elevation: 0,
      color: AppColors.lightGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Activity icon
            CircleAvatar(
              backgroundColor: AppColors.lilac.withOpacity(0.2),
              radius: 18,
              child: Icon(
                _eventTypeIcon(item.activityType),
                color: AppColors.lilacDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Activity info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activityLabel(item.activityType),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (item.scheduledTime != null)
                    Text(
                      item.scheduledTime!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                ],
              ),
            ),
            // Status indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _statusIcon(item.status),
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _statusLabel(item.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
