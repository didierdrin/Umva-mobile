// lib/widgets/floating_pill_nav.dart
//
// Bottom nav as a floating solid-color pill, margined off the bottom/left/
// right edges instead of docking to them like the stock BottomNavigationBar.
// Meant to sit inside a Stack, positioned by the caller.

import 'package:flutter/material.dart';

class PillNavItem {
  final IconData icon;
  final String label;
  const PillNavItem({required this.icon, required this.label});
}

class FloatingPillNav extends StatelessWidget {
  final List<PillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingPillNav({super.key, required this.items, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedColor = theme.primaryColor;
    final unselectedColor = isDark ? Colors.white60 : Colors.black45;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: itemWidth * currentIndex,
                width: itemWidth,
                top: 8,
                bottom: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final selected = index == currentIndex;
                  final item = items[index];
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => onTap(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, color: selected ? selectedColor : unselectedColor, size: 24),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? selectedColor : unselectedColor,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
