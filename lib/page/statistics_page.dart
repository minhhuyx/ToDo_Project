import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart'; // import provider

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe TaskProvider
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final isLoading = taskProvider.isLoading;

    final completed = tasks.where((t) => t['completed'] == true).length;
    final pending = tasks.where((t) => t['completed'] == false).length;
    final total = completed + pending;
    final completedPercentage = total > 0 ? (completed / total * 100).toStringAsFixed(1) : "0.0";
    final pendingPercentage = total > 0 ? (pending / total * 100).toStringAsFixed(1) : "0.0";

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Task Statistics",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: completed.toDouble(),
                    color: Colors.green,
                    title: "$completedPercentage%",
                    radius: 80,
                    titleStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: pending.toDouble(),
                    color: Colors.red,
                    title: "$pendingPercentage%",
                    radius: 80,
                    titleStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(color: Colors.green, text: "Completed"),
              const SizedBox(width: 20),
              _buildLegend(color: Colors.red, text: "Pending"),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Total', total, Colors.blue),
                _buildStatCard('Completed', completed, Colors.green),
                _buildStatCard('Pending', pending, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
