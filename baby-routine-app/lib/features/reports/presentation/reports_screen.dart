import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../controllers/report_controller.dart';
import '../models/report_data.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReport = 'sleep';
  DateTimeRange? _dateRange;
  bool _isLoading = false;
  String? _error;

  // Holds fetched data
  List<SleepReportItem> _sleepData = [];
  List<FeedingReportItem> _feedingData = [];
  List<DiapersReportItem> _diapersData = [];
  List<GrowthReportItem> _growthData = [];
  List<MedicationReportItem> _medicationData = [];

  static const _reportTypes = [
    {'value': 'sleep', 'label': 'Sono', 'icon': Icons.bedtime},
    {'value': 'feeding', 'label': 'Alimentação', 'icon': Icons.restaurant},
    {'value': 'diapers', 'label': 'Fraldas', 'icon': Icons.baby_changing_station},
    {'value': 'growth', 'label': 'Crescimento', 'icon': Icons.trending_up},
    {'value': 'medication', 'label': 'Medicação', 'icon': Icons.medication},
  ];

  String get _reportLabel {
    final item = _reportTypes.firstWhere((t) => t['value'] == _selectedReport);
    return item['label'] as String;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final controller = ref.read(reportControllerProvider.notifier);
      final start = _dateRange != null
          ? DateFormat('yyyy-MM-dd').format(_dateRange!.start)
          : null;
      final end = _dateRange != null
          ? DateFormat('yyyy-MM-dd').format(_dateRange!.end)
          : null;

      switch (_selectedReport) {
        case 'sleep':
          _sleepData = await controller.getSleepReport(
            startDate: start,
            endDate: end,
          );
          break;
        case 'feeding':
          _feedingData = await controller.getFeedingReport(
            startDate: start,
            endDate: end,
          );
          break;
        case 'diapers':
          _diapersData = await controller.getDiapersReport(
            startDate: start,
            endDate: end,
          );
          break;
        case 'growth':
          _growthData = await controller.getGrowthReport(
            startDate: start,
            endDate: end,
          );
          break;
        case 'medication':
          _medicationData = await controller.getMedicationReport(
            startDate: start,
            endDate: end,
          );
          break;
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar relatório';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: _dateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.lilacDark,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadReport();
    }
  }

  Widget _buildBarChart({
    required List<BarChartGroupData> barGroups,
    required List<String> labels,
    double? maxY,
  }) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          maxY: maxY ?? 0,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 9, color: AppColors.textGray),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY != null && maxY > 0 ? (maxY / 4) : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.lightGray,
              strokeWidth: 1,
            ),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildSleepChart() {
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    double maxY = 0;

    for (var i = 0; i < _sleepData.length; i++) {
      final item = _sleepData[i];
      final date = DateFormat('dd/MM', 'pt_BR').format(DateTime.parse(item.date));
      labels.add(date);
      final value = item.totalDurationMin / 60; // Convert minutes to hours
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: AppColors.lilac,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      if (value > maxY) maxY = value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duração do sono por dia (horas)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),
        _buildBarChart(
          barGroups: barGroups,
          labels: labels,
          maxY: maxY > 0 ? (maxY * 1.2).ceilToDouble() : 10,
        ),
      ],
    );
  }

  Widget _buildFeedingChart() {
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    double maxY = 0;

    for (var i = 0; i < _feedingData.length; i++) {
      final item = _feedingData[i];
      final date = DateFormat('dd/MM', 'pt_BR').format(DateTime.parse(item.date));
      labels.add(date);
      final total = (item.bottle + item.breast + item.solids).toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.bottle.toDouble(),
              color: AppColors.lilacDark,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: item.breast.toDouble(),
              color: AppColors.mint,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: item.solids.toDouble(),
              color: AppColors.peach,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );

      if (total > maxY) maxY = total;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alimentações por dia (quantidade)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _legendItem('Mamadeira', AppColors.lilacDark),
            const SizedBox(width: 12),
            _legendItem('Peito', AppColors.mint),
            const SizedBox(width: 12),
            _legendItem('Sólidos', AppColors.peach),
          ],
        ),
        const SizedBox(height: 16),
        _buildBarChart(
          barGroups: barGroups,
          labels: labels,
          maxY: maxY > 0 ? (maxY * 1.2).ceilToDouble() : 10,
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
      ],
    );
  }

  Widget _buildDiapersChart() {
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    double maxY = 0;

    for (var i = 0; i < _diapersData.length; i++) {
      final item = _diapersData[i];
      final date = DateFormat('dd/MM', 'pt_BR').format(DateTime.parse(item.date));
      labels.add(date);
      final total = (item.pee + item.poop + item.both).toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.pee.toDouble(),
              color: AppColors.warning,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: item.poop.toDouble(),
              color: AppColors.lilacDark,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: item.both.toDouble(),
              color: AppColors.mint,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );

      if (total > maxY) maxY = total;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trocas de fralda por dia (quantidade)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _legendItem('Xixi', AppColors.warning),
            const SizedBox(width: 12),
            _legendItem('Cocô', AppColors.lilacDark),
            const SizedBox(width: 12),
            _legendItem('Ambos', AppColors.mint),
          ],
        ),
        const SizedBox(height: 16),
        _buildBarChart(
          barGroups: barGroups,
          labels: labels,
          maxY: maxY > 0 ? (maxY * 1.2).ceilToDouble() : 10,
        ),
      ],
    );
  }

  Widget _buildGrowthChart() {
    if (_growthData.isEmpty) {
      return const Center(
        child: Text('Nenhum dado de crescimento disponível',
            style: TextStyle(color: AppColors.textGray)),
      );
    }

    final spots = <FlSpot>[];
    final labels = <String>[];
    final dateLabelsMap = <String, String>{};

    for (var i = 0; i < _growthData.length; i++) {
      final item = _growthData[i];
      final label = DateFormat('dd/MM', 'pt_BR').format(item.measuredAt);
      labels.add(label);
      dateLabelsMap[i.toDouble().toString()] = label;

      if (item.weightKg != null) {
        spots.add(FlSpot(i.toDouble(), item.weightKg!));
      }
    }

    if (spots.isEmpty) {
      return const Center(
        child: Text('Nenhuma medição de peso disponível',
            style: TextStyle(color: AppColors.textGray)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Curva de Peso (kg)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: AppColors.lilacDark,
                  barWidth: 3,
                  isCurved: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.lilacDark,
                      strokeWidth: 2,
                      strokeColor: AppColors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.lilac.withOpacity(0.2),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textGray),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          labels[index],
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textGray),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.lightGray,
                  strokeWidth: 1,
                ),
              ),
              minY: (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1)
                  .clamp(0, double.infinity),
              maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationList() {
    if (_medicationData.isEmpty) {
      return const Center(
        child: Text('Nenhum medicamento registrado',
            style: TextStyle(color: AppColors.textGray)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicationData.length,
      itemBuilder: (context, index) {
        final item = _medicationData[index];
        final date = item.occurredAt != null
            ? DateFormat('dd/MM/yyyy', 'pt_BR').format(item.occurredAt!)
            : 'Sem data';

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.lavender,
              child: Icon(Icons.medication, color: AppColors.lilacDark),
            ),
            title: Text(
              item.medicationName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              [
                'Dose: ${item.dose}',
                if (item.reason != null) 'Motivo: ${item.reason}',
                date,
              ].join(' • '),
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadReport,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    switch (_selectedReport) {
      case 'sleep':
        return _sleepData.isEmpty
            ? const Center(child: Text('Nenhum dado disponível',
                style: TextStyle(color: AppColors.textGray)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildSleepChart(),
              );
      case 'feeding':
        return _feedingData.isEmpty
            ? const Center(child: Text('Nenhum dado disponível',
                style: TextStyle(color: AppColors.textGray)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildFeedingChart(),
              );
      case 'diapers':
        return _diapersData.isEmpty
            ? const Center(child: Text('Nenhum dado disponível',
                style: TextStyle(color: AppColors.textGray)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildDiapersChart(),
              );
      case 'growth':
        return _growthData.isEmpty
            ? const Center(child: Text('Nenhum dado disponível',
                style: TextStyle(color: AppColors.textGray)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildGrowthChart(),
              );
      case 'medication':
        return _medicationData.isEmpty
            ? const Center(child: Text('Nenhum dado disponível',
                style: TextStyle(color: AppColors.textGray)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildMedicationList(),
              );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _dateRange != null
        ? '${DateFormat('dd/MM/yyyy', 'pt_BR').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy', 'pt_BR').format(_dateRange!.end)}'
        : 'Selecionar período';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Date range picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(dateText, style: const TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.lightGray),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_dateRange != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() => _dateRange = null);
                      _loadReport();
                    },
                    icon: const Icon(Icons.clear, color: AppColors.textGray),
                    tooltip: 'Limpar período',
                  ),
                ],
              ],
            ),
          ),

          // Report type selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _reportTypes.map((type) {
                  final isSelected = _selectedReport == type['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type['label'] as String),
                      avatar: Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected ? AppColors.white : AppColors.lilacDark,
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.lilacDark,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedReport = type['value'] as String);
                          _loadReport();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 16),

          // Report body
          Expanded(child: _buildReportBody()),
        ],
      ),
    );
  }
}
