import 'package:custo_doce/domain/entities/assistant_conversation_entity.dart';

class AssistantConversationModel {
  final String id;
  final String title;
  final String? lastIntent;
  final int createdAtMs;
  final int updatedAtMs;

  const AssistantConversationModel({
    required this.id,
    required this.title,
    this.lastIntent,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  factory AssistantConversationModel.fromMap(Map<String, dynamic> map) {
    return AssistantConversationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      lastIntent: map['last_intent'] as String?,
      createdAtMs: map['created_at'] as int,
      updatedAtMs: map['updated_at'] as int,
    );
  }

  factory AssistantConversationModel.fromEntity(
    AssistantConversationEntity entity,
  ) {
    return AssistantConversationModel(
      id: entity.id,
      title: entity.title,
      lastIntent: entity.lastIntent,
      createdAtMs: entity.createdAt.millisecondsSinceEpoch,
      updatedAtMs: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'last_intent': lastIntent,
      'created_at': createdAtMs,
      'updated_at': updatedAtMs,
    };
  }

  AssistantConversationEntity toEntity() {
    return AssistantConversationEntity(
      id: id,
      title: title,
      lastIntent: lastIntent,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }
}
