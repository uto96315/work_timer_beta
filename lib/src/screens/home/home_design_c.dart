import 'package:flutter/material.dart';

import '../../models/workplace.dart';

/// Placeholder for a third home screen design ("Design C") to compare
/// alongside A/B via the switcher in [HomeScreen]. See [HomeContentB] for
/// the same note — this scaffolding comes out once a design wins.
class HomeContentC extends StatelessWidget {
  const HomeContentC({super.key, required this.workplace});

  final Workplace workplace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text('デザインCは作成中です', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
