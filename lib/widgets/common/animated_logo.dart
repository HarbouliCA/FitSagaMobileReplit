import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// An animated logo widget that displays the FitSAGA logo
/// with optional animation effects.
class AnimatedLogo extends StatefulWidget {
  /// The size of the logo (both width and height).
  final double size;
  
  /// Whether to show the text "FitSAGA" below the logo.
  final bool showText;
  
  /// Whether to animate the logo.
  final bool animate;
  
  /// The text style for the logo text.
  final TextStyle? textStyle;

  /// Creates an AnimatedLogo widget.
  const AnimatedLogo({
    Key? key,
    this.size = 120,
    this.showText = true,
    this.animate = false,
    this.textStyle,
  }) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: LogoPainter(),
            ),
          ),
        ),
        if (widget.showText) ...[
          const SizedBox(height: 16),
          Text(
            'FitSAGA',
            style: widget.textStyle ?? Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for drawing the FitSAGA logo.
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4;
    
    // Draw outer circle
    final outerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      outerPaint,
    );
    
    // Draw inner figure (stylized F for FitSAGA)
    final figurePaint = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.fill;
    
    // Create a path for the stylized F
    final path = Path();
    
    // Vertical line of F
    path.moveTo(centerX - radius * 0.3, centerY - radius * 0.6);
    path.lineTo(centerX - radius * 0.1, centerY - radius * 0.6);
    path.lineTo(centerX - radius * 0.1, centerY + radius * 0.6);
    path.lineTo(centerX - radius * 0.3, centerY + radius * 0.6);
    path.close();
    
    // Top horizontal line of F
    path.moveTo(centerX - radius * 0.3, centerY - radius * 0.6);
    path.lineTo(centerX - radius * 0.3, centerY - radius * 0.4);
    path.lineTo(centerX + radius * 0.4, centerY - radius * 0.4);
    path.lineTo(centerX + radius * 0.4, centerY - radius * 0.6);
    path.close();
    
    // Middle horizontal line of F
    path.moveTo(centerX - radius * 0.3, centerY - radius * 0.1);
    path.lineTo(centerX - radius * 0.3, centerY + radius * 0.1);
    path.lineTo(centerX + radius * 0.2, centerY + radius * 0.1);
    path.lineTo(centerX + radius * 0.2, centerY - radius * 0.1);
    path.close();
    
    canvas.drawPath(path, figurePaint);
    
    // Draw a small fitness icon
    final iconPaint = Paint()
      ..color = AppTheme.primaryDarkColor
      ..style = PaintingStyle.fill;
    
    // Dumbbell shape
    final dumbbellSize = radius * 0.3;
    final dumbbellX = centerX + radius * 0.5;
    final dumbbellY = centerY + radius * 0.3;
    
    // Left weight
    canvas.drawCircle(
      Offset(dumbbellX - dumbbellSize, dumbbellY),
      dumbbellSize * 0.4,
      iconPaint,
    );
    
    // Right weight
    canvas.drawCircle(
      Offset(dumbbellX + dumbbellSize, dumbbellY),
      dumbbellSize * 0.4,
      iconPaint,
    );
    
    // Bar connecting weights
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(dumbbellX, dumbbellY),
          width: dumbbellSize * 2,
          height: dumbbellSize * 0.2,
        ),
        Radius.circular(dumbbellSize * 0.1),
      ),
      iconPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}