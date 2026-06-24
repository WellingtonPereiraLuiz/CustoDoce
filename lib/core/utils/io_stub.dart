// Stub para compilação web — dart:io não existe na web
// ignore_for_file: avoid_classes_with_only_static_members
class File {
  final String path;
  const File(this.path);
  Future<File> writeAsBytes(List<int> bytes) async => this;
}
