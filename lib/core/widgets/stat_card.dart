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
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hovered ? 1.02 : 1,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //------------------------------------
                // Ligne du haut
                //------------------------------------

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 28,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        widget.evolution,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                //------------------------------------
                // Valeur
                //------------------------------------

                Text(
                  widget.value,
                  style: AppTextStyles.cardValue,
                ),

                const SizedBox(height: 6),

                Text(
                  widget.title,
                  style: AppTextStyles.cardTitle,
                ),

                const SizedBox(height: 4),

                Text(
                  widget.subtitle,
                  style: AppTextStyles.small,
                ),

                const Spacer(),

                //------------------------------------
                // Ligne du bas
                //------------------------------------

                const Divider(),

                Row(
                  children: [
                    Text(
                      "Voir les détails",
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: widget.color,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}