import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebApkDownloadLink extends StatelessWidget {
  const WebApkDownloadLink({super.key, required this.url, required this.label});

  final String url;
  final String label;

  Future<void> _download() async {
    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: '_self',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: _download,
      icon: const Icon(Icons.file_download_outlined),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: const Color(0xFF1F6E8C),
        backgroundColor: const Color(0xFF1F6E8C).withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}