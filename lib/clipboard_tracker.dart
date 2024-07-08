import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'clipboard_model.dart';

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
                  DataColumn(label: Text('Tarih ve Saat')),
                  DataColumn(label: Text('Kopyalanan Metin')),
                  DataColumn(label: Text('İşlem')),
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
                                  content:
                                      Text('Metin kopyalandı: ${item.text}')),
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
