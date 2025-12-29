import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/scan_result.dart';
import '../services/history_service.dart';
import 'history_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  bool _isLoading = false;

  int _maliciousCount = 0;
  int _suspiciousCount = 0;
  int _totalEngines = 0;

  String _riskLevel = '';
  Color _riskColor = Colors.grey;
  String _riskMessage = '';

  // ⚠️ Keep your API key as-is (we'll move it later)
  final String apiKey =
      'ceace96377fae9f0ccfdb40179bfc328ecabfa05df1cecb889badec873d06f8d';

  Future<void> checkUrl() async {
    setState(() {
      _isLoading = true;
      _riskLevel = '';
    });

    final submitUrl = Uri.parse('https://www.virustotal.com/api/v3/urls');

    final submitResponse = await http.post(
      submitUrl,
      headers: {
        'x-apikey': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'url': _urlController.text.trim(),
      },
    );

    if (submitResponse.statusCode != 200) {
      setState(() => _isLoading = false);
      return;
    }

    final submitData = jsonDecode(submitResponse.body);
    final analysisId = submitData['data']['id'];

    final analysisUrl =
        Uri.parse('https://www.virustotal.com/api/v3/analyses/$analysisId');

    await Future.delayed(const Duration(seconds: 3));

    final analysisResponse = await http.get(
      analysisUrl,
      headers: {'x-apikey': apiKey},
    );

    final analysisData = jsonDecode(analysisResponse.body);
    final results =
        analysisData['data']['attributes']['results'] as Map;

    int malicious = 0;
    int suspicious = 0;

    results.forEach((_, value) {
      if (value['result'] == 'malicious') malicious++;
      if (value['result'] == 'suspicious') suspicious++;
    });

    final total = results.length;
    final detections = malicious + suspicious;

    String risk;
    Color color;
    String message;

    if (detections == 0) {
      risk = 'Safe';
      color = Colors.green;
      message = 'No security vendors flagged this URL.';
    } else if (detections <= 2) {
      risk = 'Suspicious';
      color = Colors.orange;
      message =
          'Some security vendors flagged this URL. Proceed with caution.';
    } else {
      risk = 'Dangerous';
      color = Colors.red;
      message =
          'Many security vendors flagged this URL as malicious. Avoid visiting.';
    }

    // ✅ SAVE SCAN TO HISTORY (NEW)
    final scanResult = ScanResult(
      url: _urlController.text.trim(),
      malicious: malicious,
      suspicious: suspicious,
      harmless: total - malicious - suspicious,
      timestamp: DateTime.now(),
    );

    await HistoryService.saveScan(scanResult);

    setState(() {
      _maliciousCount = malicious;
      _suspiciousCount = suspicious;
      _totalEngines = total;
      _riskLevel = risk;
      _riskColor = color;
      _riskMessage = message;
      _isLoading = false;
    });
  }

  Widget buildResultCard() {
    if (_riskLevel.isEmpty) return const SizedBox();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _riskColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: _riskColor),
                const SizedBox(width: 8),
                Text(
                  'Risk Level: $_riskLevel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _riskColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Detections: ${_maliciousCount + _suspiciousCount} / $_totalEngines',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _riskMessage,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Browsing Companion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter a URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : checkUrl,
              child: const Text('Check URL'),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
            buildResultCard(),
          ],
        ),
      ),
    );
  }
}
