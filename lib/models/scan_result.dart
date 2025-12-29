class ScanResult {
  final String url;
  final int malicious;
  final int suspicious;
  final int harmless;
  final DateTime timestamp;

  ScanResult({
    required this.url,
    required this.malicious,
    required this.suspicious,
    required this.harmless,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'malicious': malicious,
      'suspicious': suspicious,
      'harmless': harmless,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      url: json['url'],
      malicious: json['malicious'],
      suspicious: json['suspicious'],
      harmless: json['harmless'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
