enum AssistantActionStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  failed('failed');

  final String value;
  const AssistantActionStatus(this.value);

  static AssistantActionStatus fromString(String value) {
    return AssistantActionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AssistantActionStatus.pending,
    );
  }
}
