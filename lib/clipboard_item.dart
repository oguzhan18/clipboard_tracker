import 'package:hive/hive.dart';

part 'clipboard_item.g.dart';

@HiveType(typeId: 0)
class ClipboardItem extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime timestamp;

  ClipboardItem({required this.text, required this.timestamp});
}
