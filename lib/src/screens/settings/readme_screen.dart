import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReadmeScreen extends StatefulWidget {
  const ReadmeScreen({super.key});

  @override
  State<ReadmeScreen> createState() => _ReadmeScreenState();
}

class _ReadmeScreenState extends State<ReadmeScreen> {
  late final Future<String> _contentFuture = rootBundle.loadString('README.md');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('README')),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('読み込みに失敗しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          );
        },
      ),
    );
  }
}
