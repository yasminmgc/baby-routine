import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final String id;
  final String babyId;
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.babyId,
    required this.content,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? babyId,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Note(id: $id, content: ${content.substring(0, content.length.clamp(0, 30))})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          babyId == other.babyId &&
          content == other.content;

  @override
  int get hashCode => Object.hash(id, babyId, content);
}
