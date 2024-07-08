import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'clipboard_item.dart';

class ClipboardModel with ChangeNotifier {
  Box<ClipboardItem> _clipboardBox;

  ClipboardModel() : _clipboardBox = Hive.box<ClipboardItem>('clipboardItems');

  List<ClipboardItem> get clipboardHistory => _clipboardBox.values.toList();

  void addClipboardItem(String item) {
    final newItem = ClipboardItem(text: item, timestamp: DateTime.now());
    _clipboardBox.add(newItem);
    notifyListeners();
  }

  void copyToClipboard(String item) {
    Clipboard.setData(ClipboardData(text: item));
  }
}
