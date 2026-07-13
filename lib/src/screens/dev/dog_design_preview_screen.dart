import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/dog_design_variants.dart';

/// Dev-only panel for comparing candidate dog designs side by side before
/// picking one for the real home-screen track — see [DogVariantPainter]
/// subclasses for the actual drawing code.
class DogDesignPreviewScreen extends StatefulWidget {
  const DogDesignPreviewScreen({super.key});

  @override
  State<DogDesignPreviewScreen> createState() => _DogDesignPreviewScreenState();
}

class _DogDesignPreviewScreenState extends State<DogDesignPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('犬種デザイン候補（開発用）')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DesignCard(
                title: '柴犬',
                subtitle: '立ち耳・標準体型の基準デザイン',
                painter: ShibaDogPainter(t),
              ),
              const SizedBox(height: 16),
              _DesignCard(
                title: 'ゴールデンレトリバー',
                subtitle: '黄金色・大きな垂れ耳・やや長く広い鼻先',
                painter: GoldenRetrieverDogPainter(t),
              ),
              const SizedBox(height: 16),
              _DesignCard(
                title: 'ダックスフンド',
                subtitle: '長い胴体＋短い脚（胴長短足）・長い垂れ耳・長い鼻先',
                painter: DachshundDogPainter(t),
              ),
              const SizedBox(height: 16),
              _DesignCard(
                title: 'ダルメシアン',
                subtitle: '白地に黒斑点・垂れ耳',
                painter: DalmatianDogPainter(t),
              ),
              const SizedBox(height: 16),
              _DesignCard(
                title: 'コーギー',
                subtitle: '大きな立ち耳・短い脚・短めの鼻先',
                painter: CorgiDogPainter(t),
              ),
              const SizedBox(height: 16),
              _DesignCard(
                title: 'ゴールデンレトリバー（おすわり・参考画像再現）',
                subtitle: '参考画像をそのまま再現。あご上げ・丸い垂れ耳・おすわりの姿勢',
                painter: SittingGoldenRetrieverPainter(t),
              ),
              const SizedBox(height: 28),
              Text(
                '既製イラスト（Twemoji, MITライセンス）',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '自作の図形ではなく、プロがデザインした絵文字SVGをそのまま使う場合の見た目。',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 12),
              _SvgDesignCard(
                title: '🐶 dog face（Twemoji）',
                assetPath: 'assets/dog_emoji/dog_face.svg',
                bounce: t,
              ),
              const SizedBox(height: 16),
              _SvgDesignCard(
                title: '🐕 dog（Twemoji）',
                assetPath: 'assets/dog_emoji/dog.svg',
                bounce: t,
              ),
              const SizedBox(height: 16),
              _SvgDesignCard(
                title: '🐩 poodle（Twemoji）',
                assetPath: 'assets/dog_emoji/poodle.svg',
                bounce: t,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SvgDesignCard extends StatelessWidget {
  const _SvgDesignCard({required this.title, required this.assetPath, required this.bounce});

  final String title;
  final String assetPath;

  /// 0..1, looping — reused to bounce the (otherwise static) illustration
  /// slightly, just so it doesn't look frozen next to the animated
  /// hand-drawn cards.
  final double bounce;

  @override
  Widget build(BuildContext context) {
    final offset = -6 * math.sin(bounce * 2 * math.pi).abs();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: SvgPicture.asset(assetPath, width: 72, height: 72),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(assetPath, width: 30, height: 30),
                ),
                const SizedBox(height: 2),
                Text('実サイズ', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.outline)),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({
    required this.title,
    required this.subtitle,
    required this.painter,
  });

  final String title;
  final String subtitle;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(size: const Size.square(72), painter: painter),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The actual dog track renders this small — worth checking
                // a design still reads at real size, not just enlarged.
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(size: const Size.square(30), painter: painter),
                ),
                const SizedBox(height: 2),
                Text('実サイズ', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.outline)),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
