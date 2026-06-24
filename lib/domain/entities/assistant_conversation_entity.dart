class AssistantConversationEntity {
  final String id;
  final String title;
  final String? lastIntent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssistantConversationEntity({
    required this.id,
    required this.title,
    this.lastIntent,
    required this.createdAt,
    required this.updatedAt,
  });

  AssistantConversationEntity copyWith({
    String? id,
    String? title,
    String? Function()? lastIntent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssistantConversationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      lastIntent: lastIntent != null ? lastIntent() : this.lastIntent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
