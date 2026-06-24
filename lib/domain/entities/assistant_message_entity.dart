import 'package:custo_doce/core/enums/assistant_message_role.dart';
import 'package:custo_doce/core/enums/assistant_message_type.dart';

class AssistantMessageEntity {
  final String id;
  final String conversationId;
  final AssistantMessageRole role;
  final AssistantMessageType type;
  final String content;
  final String? metadata;
  final DateTime createdAt;

  const AssistantMessageEntity({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.type,
    required this.content,
    this.metadata,
    required this.createdAt,
  });
}
