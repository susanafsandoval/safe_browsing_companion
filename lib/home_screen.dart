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

  // TODO: Replace with your actual VirusTotal API key
  final String apiKey = 'ceace96377fae9f0ccfdb40179bfc328ecabfa05df1cecb889badec873d06f8d';

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
        Uri.parse('https://virustotal.com/api/v3/urls'),
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

        setState(() {
          _resultMessage =
              'URL submitted successfully.\nScan ID: ${data['data']['id']}';
        });
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
