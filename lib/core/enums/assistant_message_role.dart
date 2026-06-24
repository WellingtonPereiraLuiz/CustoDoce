enum AssistantMessageRole {
  user('user'),
  assistant('assistant'),
  system('system');

  final String value;
  const AssistantMessageRole(this.value);

  static AssistantMessageRole fromString(String value) {
    return AssistantMessageRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => AssistantMessageRole.assistant,
    );
  }
}
