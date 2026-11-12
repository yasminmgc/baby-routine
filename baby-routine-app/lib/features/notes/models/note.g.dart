// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
