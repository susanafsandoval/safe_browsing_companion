import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  String _resultMessage = '';
  bool _isLoading = false;

  // TODO: Move this out later (Day 13)
  final String apiKey =
      'ceace96377fae9f0ccfdb40179bfc328ecabfa05df1cecb889badec873d06f8d';

  /// -----------------------------
  /// DAY 8: FETCH SCAN RESULTS
  /// -----------------------------
  Future<void> fetchScanResults(String analysisId) async {
    final response = await http.get(
      Uri.parse('https://www.virustotal.com/api/v3/analyses/$analysisId'),
      headers: {
        'x-apikey': apiKey,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('SCAN RESULTS:');
      print(decoded);
    } else {
      print('Failed to fetch scan results');
      print('Status code: ${response.statusCode}');
      print(response.body);
    }
  }

  /// -----------------------------
  /// DAY 7: SUBMIT URL
  /// -----------------------------
  Future<void> checkUrlSafety() async {
    final String url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _resultMessage = 'Please enter a URL.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://www.virustotal.com/api/v3/urls'),
        headers: {
          'x-apikey': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'url': url,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analysisId = data['data']['id'];

        setState(() {
          _resultMessage =
              'URL submitted successfully.\nScan ID: $analysisId';
        });

        // 🔑 DAY 8 CALL — fetch analysis results
        await fetchScanResults(analysisId);
      } else {
        setState(() {
          _resultMessage =
              'Failed to check URL. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Browsing Companion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter a URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : checkUrlSafety,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Check URL'),
            ),
            const SizedBox(height: 24),
            Text(
              _resultMessage,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
