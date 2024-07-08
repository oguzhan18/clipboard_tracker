// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class ClipboardItem {
  final String text;
  final DateTime timestamp;

  ClipboardItem({required this.text, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  static ClipboardItem fromJson(Map<String, dynamic> json) => ClipboardItem(
        text: json['text'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class ClipboardModel with ChangeNotifier {
  List<ClipboardItem> _clipboardHistory = [];

  List<ClipboardItem> get clipboardHistory => _clipboardHistory;

  ClipboardModel() {
    _loadClipboardHistory();
  }

  void addClipboardItem(String item) {
    final newItem = ClipboardItem(text: item, timestamp: DateTime.now());
    _clipboardHistory.add(newItem);
    _saveClipboardHistory();
    notifyListeners();
  }

  void copyToClipboard(String item) {
    Clipboard.setData(ClipboardData(text: item));
  }

  void _saveClipboardHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history =
        _clipboardHistory.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('clipboardHistory', history);
  }

  void _loadClipboardHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? history = prefs.getStringList('clipboardHistory');
    if (history != null) {
      _clipboardHistory = history
          .map((item) => ClipboardItem.fromJson(json.decode(item)))
          .toList();
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClipboardModel(),
      child: MaterialApp(
        home: ClipboardTracker(),
      ),
    );
  }
}

class ClipboardTracker extends StatefulWidget {
  @override
  _ClipboardTrackerState createState() => _ClipboardTrackerState();
}

class _ClipboardTrackerState extends State<ClipboardTracker> {
  static const platform = MethodChannel('clipboard_tracker');

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      if (call.method == 'clipboardChanged') {
        final copiedText = call.arguments as String;
        Provider.of<ClipboardModel>(context, listen: false)
            .addClipboardItem(copiedText);
        print("Copied text in Flutter: $copiedText");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clipboardHistory =
        Provider.of<ClipboardModel>(context).clipboardHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text('Clipboard Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Date and time')),
                  DataColumn(label: Text('Copied Text')),
                  DataColumn(label: Text('Process')),
                ],
                rows: clipboardHistory.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('dd MMM yyyy, HH:mm:ss')
                          .format(item.timestamp))),
                      DataCell(Text(item.text)),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {
                            Provider.of<ClipboardModel>(context, listen: false)
                                .copyToClipboard(item.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Text copied: ${item.text}')),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
