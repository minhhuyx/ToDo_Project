import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ungdung_ghichu/widget/custom_color.dart';
import '../providers/task_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final completed = taskProvider.completedTasks;
        final pending = taskProvider.pendingTasks;
        final pendingSync = taskProvider.pendingSyncTasks;
        final total = taskProvider.totalTasks;

        final completedPercentage = total > 0 ? (completed / total * 100).toStringAsFixed(1) : "0.0";
        final pendingPercentage = total > 0 ? (pending / total * 100).toStringAsFixed(1) : "0.0";

        // Nếu không có dữ liệu, hiển thị thông báo ở giữa màn hình
        if (total == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_outline, size: 64,  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu thống kê',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of( context, ).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          );
        }

        // Nếu có dữ liệu, hiển thị các thành phần thống kê
        return SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Sync status indicator
                if (pendingSync > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync, color: Colors.orange[700], size: 16),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => taskProvider.syncPendingTasks(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Đồng bộ ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Pie Chart
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: completed.toDouble(),
                          color: AppColors.primary,
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

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend(color: AppColors.primary, text: "Hoàn thành"),
                    const SizedBox(width: 20),
                    _buildLegend(color: Colors.red, text: "Chưa hoàn thành"),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats Cards
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // hoặc spaceBetween
                    children: [
                      Expanded(child: _buildStatCard('Tổng số', total, Colors.blue)),
                      Expanded(child: _buildStatCard('Hoàn thành', completed, AppColors.primary)),
                      Expanded(child: _buildStatCard('Chưa hoàn thành', pending, Colors.red)),
                    ],
                  )

                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 14)),
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
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}