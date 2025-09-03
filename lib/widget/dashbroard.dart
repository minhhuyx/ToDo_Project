import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_color.dart';

class TaskStatsCard extends StatelessWidget {
  final int todayCount;
  final int previousCount;
  final int futureCount;

  const TaskStatsCard({
    super.key,
    required this.todayCount,
    required this.previousCount,
    required this.futureCount,
  });

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary, // màu viền
          width: 2,           // độ dày viền
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Previously", previousCount, Colors.red),
          _buildStatItem("Today", todayCount, Colors.blue),
          _buildStatItem("Future", futureCount, Colors.green),
        ],
      ),
    );
  }
}