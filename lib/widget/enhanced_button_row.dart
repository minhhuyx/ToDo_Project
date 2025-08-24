// File: lib/widgets/enhanced_button_row.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widget/enhanced_button_row.dart';

class EnhancedButtonRow extends StatefulWidget {
  final Function()? onNotePressed;
  final Function()? onCalendarPressed;
  final Function()? onAchievementPressed;

  const EnhancedButtonRow({
    Key? key,
    this.onNotePressed,
    this.onCalendarPressed,
    this.onAchievementPressed,
  }) : super(key: key);

  @override
  _EnhancedButtonRowState createState() => _EnhancedButtonRowState();
}

class _EnhancedButtonRowState extends State<EnhancedButtonRow>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;

  @override
  void initState() {
    super.initState();

    // Tạo animation controllers cho từng nút
    _controllers = List.generate(3, (index) =>
        AnimationController(
          duration: Duration(milliseconds: 200),
          vsync: this,
        )
    );

    // Tạo scale animations
    _scaleAnimations = _controllers.map((controller) =>
        Tween<double>(begin: 1.0, end: 0.9).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut)
        )
    ).toList();

    // Tạo rotation animations
    _rotationAnimations = _controllers.map((controller) =>
        Tween<double>(begin: 0.0, end: 0.1).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut)
        )
    ).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedButton({
    required int index,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: Transform.rotate(
            angle: _rotationAnimations[index].value,
            child: GestureDetector(
              onTapDown: (_) {
                _controllers[index].forward();
                HapticFeedback.lightImpact();
              },
              onTapUp: (_) {
                _controllers[index].reverse();
                Future.delayed(Duration(milliseconds: 100), () {
                  onTap();
                });
              },
              onTapCancel: () {
                _controllers[index].reverse();
              },
              child: Container(
                width: _getButtonSize(context),
                height: _getButtonSize(context),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: backgroundColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: _getIconSize(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Responsive button size
  double _getButtonSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return 45.0; // Màn hình nhỏ
    } else if (screenWidth < 600) {
      return 50.0; // Màn hình trung bình
    } else {
      return 60.0; // Màn hình lớn
    }
  }

  // Responsive icon size
  double _getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return 20.0;
    } else if (screenWidth < 600) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Nút 1 - Ghi chú
          _buildAnimatedButton(
            index: 0,
            icon: Icons.note_alt_outlined,
            backgroundColor: Colors.blue[100]!,
            iconColor: Colors.blue[700]!,
            onTap: widget.onNotePressed ?? () {
              print("Nút ghi chú được nhấn");
            },
          ),

          // Nút 2 - Lịch
          _buildAnimatedButton(
            index: 1,
            icon: Icons.calendar_today_outlined,
            backgroundColor: Colors.purple[100]!,
            iconColor: Colors.purple[700]!,
            onTap: widget.onCalendarPressed ?? () {
              print("Nút lịch được nhấn");
            },
          ),

          // Nút 3 - Thành tích
          _buildAnimatedButton(
            index: 2,
            icon: Icons.emoji_events_outlined,
            backgroundColor: Colors.amber[100]!,
            iconColor: Colors.orange[700]!,
            onTap: widget.onAchievementPressed ?? () {
              print("Nút thành tích được nhấn");
            },
          ),
        ],
      ),
    );
  }
}