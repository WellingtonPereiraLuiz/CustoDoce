import 'package:custo_doce/core/enums/assistant_message_role.dart';
import 'package:custo_doce/core/enums/assistant_message_type.dart';
import 'package:custo_doce/domain/entities/assistant_message_entity.dart';

class AssistantMessageModel {
  final String id;
  final String conversationId;
  final String role;
  final String type;
  final String content;
  final String? metadata;
  final int createdAtMs;

  const AssistantMessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.type,
    required this.content,
    this.metadata,
    required this.createdAtMs,
  });

  factory AssistantMessageModel.fromMap(Map<String, dynamic> map) {
    return AssistantMessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      role: map['role'] as String,
      type: map['type'] as String,
      content: map['content'] as String,
      metadata: map['metadata'] as String?,
      createdAtMs: map['created_at'] as int,
    );
  }

  factory AssistantMessageModel.fromEntity(AssistantMessageEntity entity) {
    return AssistantMessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      role: entity.role.value,
      type: entity.type.value,
      content: entity.content,
      metadata: entity.metadata,
      createdAtMs: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'type': type,
      'content': content,
      'metadata': metadata,
      'created_at': createdAtMs,
    };
  }

  AssistantMessageEntity toEntity() {
    return AssistantMessageEntity(
      id: id,
      conversationId: conversationId,
      role: AssistantMessageRole.fromString(role),
      type: AssistantMessageType.fromString(type),
      content: content,
      metadata: metadata,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }
}
