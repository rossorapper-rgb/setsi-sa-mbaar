import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import 'app_card.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final String evolution;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.evolution,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 250;
        final iconSize = compact ? 22.0 : 26.0;
        final iconBox = compact ? 42.0 : 48.0;
        final valueSize = compact ? 24.0 : 30.0;

        return MouseRegion(
          onEnter: (_) => setState(() => hovered = true),
          onExit: (_) => setState(() => hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: hovered
                ? (Matrix4.identity()..translate(0.0, -3.0))
                : Matrix4.identity(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: widget.onTap,
                child: AppCard(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 14,
                    vertical: compact ? 9 : 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: iconBox,
                        height: iconBox,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: iconSize,
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 7 : 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: compact ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: compact ? 13 : 14,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardValue.copyWith(
                                fontSize: valueSize,
                                color: widget.color,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.small.copyWith(
                                fontSize: compact ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.onTap != null && !compact) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: widget.color,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}