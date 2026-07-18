import 'package:flutter/material.dart';

import 'pixel_ui.dart';

class FloatingNavDestination {
  const FloatingNavDestination({
    required this.icon,
    required this.selectedIcon,
  });

  final IconData icon;
  final IconData selectedIcon;
}

/// A floating, label-less bottom navigation bar in the style of Instagram's
/// tab bar: an icon-only pill that hovers above the screen content instead
/// of docking flush with the bottom edge.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<FloatingNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: PixelPanel(
          padding: EdgeInsets.zero,
          color: PixelColors.panel,
          child: SizedBox(
            height: 56,
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: destinations.length <= 1
                      ? Alignment.center
                      : Alignment(-1 + 2 * selectedIndex / (destinations.length - 1), 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / destinations.length,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      _NavIconButton(
                        destination: destinations[i],
                        selected: i == selectedIndex,
                        selectedColor: colorScheme.primary,
                        unselectedColor: PixelColors.ink,
                        onTap: () => onDestinationSelected(i),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.destination,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final FloatingNavDestination destination;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(
            selected ? destination.selectedIcon : destination.icon,
            color: selected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
