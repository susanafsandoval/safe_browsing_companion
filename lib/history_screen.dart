import 'package:flutter/material.dart';
import 'models/scan_result.dart';
import 'services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanResult> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final results = await HistoryService.getHistory();
    setState(() {
      history = results;
    });
  }

  Color getRiskColor(ScanResult result) {
    if (result.malicious > 0) return Colors.red;
    if (result.suspicious > 0) return Colors.orange;
    return Colors.green;
  }

  String getRiskLabel(ScanResult result) {
    if (result.malicious > 0) return 'Dangerous';
    if (result.suspicious > 0) return 'Suspicious';
    return 'Safe';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: history.isEmpty
          ? const Center(child: Text('No scans yet'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final scan = history[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      Icons.security,
                      color: getRiskColor(scan),
                    ),
                    title: Text(
                      scan.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      getRiskLabel(scan),
                      style: TextStyle(color: getRiskColor(scan)),
                    ),
                    trailing: Text(
                      '${scan.timestamp.hour.toString().padLeft(2, '0')}:${scan.timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
