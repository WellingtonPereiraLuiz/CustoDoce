enum AssistantMessageType {
  text('text'),
  image('image'),
  actionPreview('action_preview'),
  actionResult('action_result');

  final String value;
  const AssistantMessageType(this.value);

  static AssistantMessageType fromString(String value) {
    return AssistantMessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AssistantMessageType.text,
    );
  }
}
