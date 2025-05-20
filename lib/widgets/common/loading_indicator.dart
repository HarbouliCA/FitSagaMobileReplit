import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool overlay;
  final bool fullScreen;
  final double size;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.overlay = false,
    this.fullScreen = false,
    this.size = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            strokeWidth: 4.0,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (overlay) {
      return Stack(
        children: [
          const Opacity(
            opacity: 0.6,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
          Center(child: loadingWidget),
        ],
      );
    }

    if (fullScreen) {
      return Scaffold(
        body: Center(
          child: loadingWidget,
        ),
      );
    }

    return Center(
      child: loadingWidget,
    );
  }
}

class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    Key? key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const SizedBox.shrink(),
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(
                _animation.value - 1.0,
                0.0,
              ),
              end: Alignment(
                _animation.value,
                0.0,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  final double height;
  final bool hasLeading;
  final bool hasTrailing;
  final int lineCount;

  const ListItemSkeleton({
    Key? key,
    this.height = 80.0,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lineCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasLeading) ...[
              const SkeletonLoading(
                width: 48,
                height: 48,
                borderRadius: 24,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < lineCount; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    SkeletonLoading(
                      width: i == 0 ? double.infinity : 120,
                      height: i == 0 ? 20 : 16,
                    ),
                  ],
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: 16),
              const SkeletonLoading(
                width: 24,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final bool hasImage;
  final int lineCount;
  final double borderRadius;

  const CardSkeleton({
    Key? key,
    this.height = 200,
    this.width = double.infinity,
    this.hasImage = true,
    this.lineCount = 3,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              SkeletonLoading(
                width: double.infinity,
                height: height * 0.5,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < lineCount; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    SkeletonLoading(
                      width: i == 0 ? double.infinity : 150 - (i * 30),
                      height: i == 0 ? 24 : 16,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}