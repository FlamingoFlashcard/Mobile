import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.size = 40.0,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.photo_library_outlined,
                  color: widget.color ?? Theme.of(context).primaryColor,
                  size: widget.size * 0.4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 