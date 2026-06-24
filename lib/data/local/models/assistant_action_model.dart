import 'package:custo_doce/core/enums/assistant_action_status.dart';
import 'package:custo_doce/core/enums/assistant_action_type.dart';
import 'package:custo_doce/domain/entities/assistant_action_entity.dart';

class AssistantActionModel {
  final String id;
  final String conversationId;
  final String type;
  final String status;
  final String summary;
  final String? payload;
  final String? targetId;
  final int createdAtMs;

  const AssistantActionModel({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.status,
    required this.summary,
    this.payload,
    this.targetId,
    required this.createdAtMs,
  });

  factory AssistantActionModel.fromMap(Map<String, dynamic> map) {
    return AssistantActionModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      summary: map['summary'] as String,
      payload: map['payload'] as String?,
      targetId: map['target_id'] as String?,
      createdAtMs: map['created_at'] as int,
    );
  }

  factory AssistantActionModel.fromEntity(AssistantActionEntity entity) {
    return AssistantActionModel(
      id: entity.id,
      conversationId: entity.conversationId,
      type: entity.type.value,
      status: entity.status.value,
      summary: entity.summary,
      payload: entity.payload,
      targetId: entity.targetId,
      createdAtMs: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'type': type,
      'status': status,
      'summary': summary,
      'payload': payload,
      'target_id': targetId,
      'created_at': createdAtMs,
    };
  }

  AssistantActionEntity toEntity() {
    return AssistantActionEntity(
      id: id,
      conversationId: conversationId,
      type: AssistantActionType.fromString(type),
      status: AssistantActionStatus.fromString(status),
      summary: summary,
      payload: payload,
      targetId: targetId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }
}
