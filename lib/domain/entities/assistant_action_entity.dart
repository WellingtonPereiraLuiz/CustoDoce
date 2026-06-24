import 'package:custo_doce/core/enums/assistant_action_status.dart';
import 'package:custo_doce/core/enums/assistant_action_type.dart';

class AssistantActionEntity {
  final String id;
  final String conversationId;
  final AssistantActionType type;
  final AssistantActionStatus status;
  final String summary;
  final String? payload;
  final String? targetId;
  final DateTime createdAt;

  const AssistantActionEntity({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.status,
    required this.summary,
    this.payload,
    this.targetId,
    required this.createdAt,
  });
}
