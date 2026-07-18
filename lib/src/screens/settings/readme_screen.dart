import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ReadmeScreen extends StatefulWidget {
  const ReadmeScreen({super.key});

  @override
  State<ReadmeScreen> createState() => _ReadmeScreenState();
}

class _ReadmeScreenState extends State<ReadmeScreen> {
  late final Future<String> _contentFuture = rootBundle.loadString('docs/VISION.md');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VISION')),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('読み込みに失敗しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.all(16),
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 14, height: 1.6),
              code: TextStyle(
                fontSize: 13,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          );
        },
      ),
    );
  }
}
