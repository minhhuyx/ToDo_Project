import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClockScreen extends StatefulWidget {
  final double size;

  const ClockScreen({super.key, this.size = 200}); // 👈 cho phép chỉnh size

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late DateTime _dateTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _dateTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Đồng hồ kim
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: ClockPainter(_dateTime)),
        ),
        const SizedBox(height: 30),

        // Giờ dạng số
        Text(
          "${_dateTime.hour.toString().padLeft(2, '0')}:"
          "${_dateTime.minute.toString().padLeft(2, '0')}:"
          "${_dateTime.second.toString().padLeft(2, '0')}",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Ngày tháng
        Text(
          "${_dateTime.day}/${_dateTime.month}/${_dateTime.year}",
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillBrush =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF18A5A7), Color(0xFFBFFFC7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCircle(center: center, radius: radius));
    final outlineBrush =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    // Vẽ mặt đồng hồ
    canvas.drawCircle(center, radius, fillBrush);
    canvas.drawCircle(center, radius, outlineBrush);

    // Vẽ các vạch giờ
    final tickBrush =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    for (int i = 0; i < 60; i++) {
      final angle = (pi / 30) * i;
      final start = Offset(
        center.dx +
            (radius - (i % 5 == 0 ? radius * 0.15 : radius * 0.08)) *
                cos(angle),
        center.dy +
            (radius - (i % 5 == 0 ? radius * 0.15 : radius * 0.08)) *
                sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, tickBrush);
    }

    // Kim giờ
    final hourHandBrush =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;
    final hourAngle = (pi / 6) * (dateTime.hour % 12 + dateTime.minute / 60);
    final hourHand = Offset(
      center.dx + radius * 0.5 * cos(hourAngle),
      center.dy + radius * 0.5 * sin(hourAngle),
    );
    canvas.drawLine(center, hourHand, hourHandBrush);

    // Kim phút
    final minuteHandBrush =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
    final minuteAngle = (pi / 30) * dateTime.minute;
    final minuteHand = Offset(
      center.dx + radius * 0.7 * cos(minuteAngle),
      center.dy + radius * 0.7 * sin(minuteAngle),
    );
    canvas.drawLine(center, minuteHand, minuteHandBrush);

    // Kim giây
    final secondHandBrush =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    final secondAngle = (pi / 30) * dateTime.second;
    final secondHand = Offset(
      center.dx + radius * 0.8 * cos(secondAngle),
      center.dy + radius * 0.8 * sin(secondAngle),
    );
    canvas.drawLine(center, secondHand, secondHandBrush);

    // Chấm giữa
    final centerDotBrush = Paint()..color = Colors.black;
    canvas.drawCircle(center, radius * 0.05, centerDotBrush);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
