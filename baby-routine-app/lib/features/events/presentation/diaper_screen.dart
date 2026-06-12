import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/event_controller.dart';

class DiaperScreen extends ConsumerStatefulWidget {
  const DiaperScreen({super.key});

  @override
  ConsumerState<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends ConsumerState<DiaperScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'pee';
  String? _color;
  String _consistency = 'normal';
  bool _rash = false;
  final _notesController = TextEditingController();
  DateTime _occurredAt = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<String> _availableColors() {
    if (_type == 'pee') return ['yellow'];
    if (_type == 'poop') return ['yellow', 'green', 'brown'];
    return ['yellow', 'green', 'brown']; // both
  }

  String _colorLabel(String color) {
    switch (color) {
      case 'yellow':
        return 'Amarelo';
      case 'green':
        return 'Verde';
      case 'brown':
        return 'Marrom';
      default:
        return color;
    }
  }

  Color _colorSwatch(String color) {
    switch (color) {
      case 'yellow':
        return const Color(0xFFFFEB3B);
      case 'green':
        return const Color(0xFF8BC34A);
      case 'brown':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'pee':
        return 'Xixi';
      case 'poop':
        return 'Cocô';
      case 'both':
        return 'Ambos';
      default:
        return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'pee':
        return Icons.water_drop;
      case 'poop':
        return Icons.circle;
      case 'both':
        return Icons.layers;
      default:
        return Icons.help;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Only pee needs color = yellow automatically
    final effectiveColor = _color ?? (_type == 'pee' ? 'yellow' : null);

    final notesText = _notesController.text.trim();

    final details = <String, dynamic>{
      'type': _type,
      if (effectiveColor != null) 'color': effectiveColor,
      'consistency': _consistency,
      'rash': _rash,
    };

    try {
      await ref.read(eventControllerProvider.notifier).createEvent(
            eventType: 'diaper',
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
      AppSnackbar.showSuccess(context, 'Fralda registrada com sucesso!');
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
    final availableColors = _availableColors();

    // Ensure selected color is valid for current type
    if (_color != null && !availableColors.contains(_color)) {
      _color = null;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Registrar Fralda'),
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
              // Type selector — choice chips
              const Text(
                'Tipo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['pee', 'poop', 'both'].map((type) {
                  final selected = _type == type;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _typeIcon(type),
                          size: 18,
                          color: selected ? AppColors.white : AppColors.textDark,
                        ),
                        const SizedBox(width: 6),
                        Text(_typeLabel(type)),
                      ],
                    ),
                    selected: selected,
                    selectedColor: AppColors.lilacDark,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.white : AppColors.textDark,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (value) {
                      if (value) {
                        setState(() {
                          _type = type;
                          _color = null; // reset color on type change
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Color — only show if type != 'pee' (pee is always yellow)
              if (_type != 'pee') ...[
                const Text(
                  'Cor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableColors.map((color) {
                    final selected = _color == color;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _colorSwatch(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_colorLabel(color)),
                        ],
                      ),
                      selected: selected,
                      selectedColor: AppColors.lilac.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.lilacDark
                            : AppColors.textDark,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (value) {
                        setState(() {
                          _color = value ? color : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Consistency dropdown
              DropdownButtonFormField<String>(
                value: _consistency,
                decoration: InputDecoration(
                  labelText: 'Consistência',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'pasty', child: Text('Pastosa')),
                  DropdownMenuItem(value: 'liquid', child: Text('Líquida')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _consistency = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Rash toggle
              SwitchListTile(
                title: const Text(
                  'Assadura',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  _rash ? 'Com assadura' : 'Sem assadura',
                  style: const TextStyle(fontSize: 13),
                ),
                value: _rash,
                onChanged: (value) {
                  setState(() => _rash = value);
                },
                activeColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _rash ? AppColors.error.withOpacity(0.5) : AppColors.lightGray,
                  ),
                ),
                tileColor: AppColors.lightGray,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'Observações',
                hintText: 'Ex: Consistência normal, sem assadura',
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
