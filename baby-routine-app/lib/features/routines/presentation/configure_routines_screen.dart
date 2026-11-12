import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../controllers/routine_controller.dart';
import '../../models/routine.dart';

class ConfigureRoutinesScreen extends ConsumerStatefulWidget {
  const ConfigureRoutinesScreen({super.key});

  @override
  ConsumerState<ConfigureRoutinesScreen> createState() =>
      _ConfigureRoutinesScreenState();
}

class _ConfigureRoutinesScreenState
    extends ConsumerState<ConfigureRoutinesScreen> {
  List<Routine> _routines = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoutines();
    });
  }

  Future<void> _loadRoutines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final routines =
          await ref.read(routineControllerProvider.notifier).listRoutines();
      setState(() {
        _routines = routines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar rotinas';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRoutine(Routine routine) async {
    try {
      await ref
          .read(routineControllerProvider.notifier)
          .toggleRoutine(routine.id, !routine.active);
      await _loadRoutines();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao alterar rotina')),
        );
      }
    }
  }

  Future<void> _deleteRoutine(String routineId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir rotina'),
        content: const Text('Tem certeza que deseja excluir esta rotina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(routineControllerProvider.notifier)
            .deleteRoutine(routineId);
        await _loadRoutines();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir rotina')),
          );
        }
      }
    }
  }

  void _showRoutineDialog({Routine? existing}) {
    final activityTypeController = TextEditingController(
        text: existing?.activityType ?? '');
    final intervalController = TextEditingController(
        text: existing?.intervalMinutes?.toString() ?? '');
    final startTimeController = TextEditingController(
        text: existing?.defaultStartTime ?? '');

    Future<void> _selectTime() async {
      final initialTime = existing?.defaultStartTime != null
          ? TimeOfDay(
              hour: int.parse(existing!.defaultStartTime!.split(':')[0]),
              minute: int.parse(existing.defaultStartTime!.split(':')[1]),
            )
          : null;

      final time = await showTimePicker(
        context: context,
        initialTime: initialTime ?? const TimeOfDay(hour: 8, minute: 0),
        builder: (context, child) {
          return Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: child!,
          );
        },
      );

      if (time != null) {
        startTimeController.text =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Editar rotina' : 'Nova rotina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _activityTypes.contains(activityTypeController.text)
                      ? activityTypeController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de atividade',
                  ),
                  items: _activityTypes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (v) => activityTypeController.text = v ?? '',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: intervalController,
                  decoration: const InputDecoration(
                    labelText: 'Intervalo (minutos)',
                    hintText: 'Ex: 180',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectTime,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Horário padrão',
                        hintText: 'HH:MM',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (activityTypeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Selecione o tipo de atividade')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                try {
                  if (existing != null) {
                    await ref
                        .read(routineControllerProvider.notifier)
                        .updateRoutine(
                          existing.id,
                          activityType: activityTypeController.text,
                          intervalMinutes:
                              int.tryParse(intervalController.text),
                          defaultStartTime: startTimeController.text.isNotEmpty
                              ? startTimeController.text
                              : null,
                        );
                  } else {
                    await ref
                        .read(routineControllerProvider.notifier)
                        .createRoutine(
                          activityType: activityTypeController.text,
                          intervalMinutes:
                              int.tryParse(intervalController.text),
                          defaultStartTime: startTimeController.text.isNotEmpty
                              ? startTimeController.text
                              : null,
                        );
                  }
                  await _loadRoutines();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(existing != null
                              ? 'Erro ao atualizar rotina'
                              : 'Erro ao criar rotina')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lilacDark,
                foregroundColor: AppColors.white,
              ),
              child: Text(existing != null ? 'Salvar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'alimentação':
      case 'alimentacao':
        return Icons.restaurant;
      case 'sono':
        return Icons.bedtime;
      case 'banho':
        return Icons.bathtub;
      case 'medicação':
      case 'medicacao':
        return Icons.medication;
      case 'vacina':
        return Icons.vaccines;
      case 'consulta':
        return Icons.local_hospital;
      case 'fralda':
        return Icons.baby_changing_station;
      case 'exame':
        return Icons.biotech;
      case 'passeio':
        return Icons.directions_walk;
      default:
        return Icons.schedule;
    }
  }

  static const _activityTypes = [
    'Alimentação',
    'Sono',
    'Banho',
    'Fralda',
    'Medicação',
    'Vacina',
    'Consulta',
    'Exame',
    'Passeio',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotinas'),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadRoutines,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _routines.isEmpty
                  ? const Center(
                      child: Text('Nenhuma rotina configurada',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.textGray)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRoutines,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _routines.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final routine = _routines[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: routine.active
                                    ? AppColors.mint
                                    : AppColors.lightGray,
                                child: Icon(
                                  _activityIcon(routine.activityType),
                                  color: routine.active
                                      ? AppColors.white
                                      : AppColors.textGray,
                                ),
                              ),
                              title: Text(
                                routine.activityType,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                [
                                  if (routine.defaultStartTime != null)
                                    routine.defaultStartTime!,
                                  if (routine.intervalMinutes != null)
                                    'a cada ${routine.intervalMinutes} min',
                                ].join(' • '),
                                style: const TextStyle(
                                    color: AppColors.textGray),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: routine.active,
                                    activeColor: AppColors.lilacDark,
                                    onChanged: (_) =>
                                        _toggleRoutine(routine),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 20,
                                        color: AppColors.textGray),
                                    onPressed: () =>
                                        _showRoutineDialog(existing: routine),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: AppColors.error),
                                    onPressed: () =>
                                        _deleteRoutine(routine.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
        onPressed: () => _showRoutineDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
