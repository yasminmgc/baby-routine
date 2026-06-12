import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? time;
  final IconData icon;
  final Color? iconColor;
  final String? status;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    required this.icon,
    this.iconColor,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? _statusColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (time != null || status != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (time != null)
                      Text(
                        time!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    if (status != null) ...[
                      const SizedBox(height: 4),
                      _statusBadge(),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge() {
    final color = _statusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status!,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _statusColor() {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'missed':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.lilacDark;
    }
  }
}
