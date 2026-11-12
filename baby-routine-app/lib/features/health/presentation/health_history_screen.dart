import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/health_record_item.dart';
import '../controllers/health_controller.dart';
import '../models/health_record.dart';

class HealthHistoryScreen extends ConsumerStatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  ConsumerState<HealthHistoryScreen> createState() =>
      _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends ConsumerState<HealthHistoryScreen> {
  List<HealthRecord> _records = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedType;

  static const _typeOptions = [
    {'value': null, 'label': 'Todos'},
    {'value': 'appointment', 'label': 'Consulta'},
    {'value': 'vaccination', 'label': 'Vacina'},
    {'value': 'medication', 'label': 'Medicamento'},
    {'value': 'exam', 'label': 'Exame'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final records = await ref
          .read(healthControllerProvider.notifier)
          .listHealthRecords(type: _selectedType);
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar histórico de saúde';
        _isLoading = false;
      });
    }
  }

  IconData _iconForType(String recordType) {
    switch (recordType) {
      case 'appointment':
        return Icons.medical_services;
      case 'vaccination':
        return Icons.vaccines;
      case 'medication':
        return Icons.medication;
      case 'exam':
        return Icons.biotech;
      default:
        return Icons.local_hospital;
    }
  }

  Color _colorForType(String recordType) {
    switch (recordType) {
      case 'appointment':
        return AppColors.lilacDark;
      case 'vaccination':
        return AppColors.warning;
      case 'medication':
        return AppColors.error;
      case 'exam':
        return AppColors.mint;
      default:
        return AppColors.textGray;
    }
  }

  String _translateType(String recordType) {
    switch (recordType) {
      case 'appointment':
        return 'Consulta';
      case 'vaccination':
        return 'Vacina';
      case 'medication':
        return 'Medicamento';
      case 'exam':
        return 'Exame';
      default:
        return recordType;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Saúde'),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _typeOptions.map((option) {
                  final isSelected = _selectedType == option['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(option['label'] as String),
                      selected: isSelected,
                      selectedColor: AppColors.lilacDark,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedType =
                              option['value'] as String?;
                        });
                        _loadRecords();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(
                                  color: AppColors.error),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadRecords,
                              child:
                                  const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : _records.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum registro encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textGray,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRecords,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 8),
                              itemCount: _records.length,
                              itemBuilder: (context, index) {
                                final record =
                                    _records[index];
                                return HealthRecordItem(
                                  title: record.title,
                                  subtitle:
                                      _translateType(
                                          record.recordType),
                                  date: _formatDate(
                                      record.occurredAt),
                                  icon: _iconForType(
                                      record.recordType),
                                  iconColor: _colorForType(
                                      record.recordType),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
