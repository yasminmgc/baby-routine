import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notes =
          await ref.read(noteControllerProvider.notifier).listNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar anotações';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir anotação'),
        content: const Text('Tem certeza que deseja excluir esta anotação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(noteControllerProvider.notifier)
            .deleteNote(noteId);
        await _loadNotes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir anotação')),
          );
        }
      }
    }
  }

  void _showNoteDialog({Note? existing}) {
    final contentController =
        TextEditingController(text: existing?.content ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Editar anotação' : 'Nova anotação'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Conteúdo',
              hintText: 'Digite sua anotação...',
            ),
            maxLines: 5,
            maxLength: 1000,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'O conteúdo é obrigatório';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(ctx);

              try {
                if (existing != null) {
                  await ref
                      .read(noteControllerProvider.notifier)
                      .updateNote(existing.id, contentController.text.trim());
                } else {
                  await ref
                      .read(noteControllerProvider.notifier)
                      .createNote(contentController.text.trim());
                }
                await _loadNotes();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(existing != null
                            ? 'Erro ao atualizar anotação'
                            : 'Erro ao criar anotação')),
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours} h';
    } else {
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações'),
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
                        onPressed: _loadNotes,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _notes.isEmpty
                  ? const Center(
                      child: Text('Nenhuma anotação',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.textGray)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotes,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Dismissible(
                            key: Key(note.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              await _deleteNote(note.id);
                              return false; // We handle removal via _loadNotes
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.error,
                              child: const Icon(Icons.delete,
                                  color: AppColors.white),
                            ),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onLongPress: () =>
                                    _showNoteDialog(existing: note),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(note.createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textGray,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              size: 20,
                                              color: AppColors.textGray,
                                            ),
                                            itemBuilder: (_) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Editar'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        size: 18,
                                                        color: AppColors
                                                            .error),
                                                    SizedBox(width: 8),
                                                    Text('Excluir',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .error)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showNoteDialog(
                                                    existing: note);
                                              } else if (value == 'delete') {
                                                _deleteNote(note.id);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note.content,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: AppColors.textDark,
                                        ),
                                        maxLines: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
