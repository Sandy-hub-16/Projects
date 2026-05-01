import 'dart:math';
import 'package:flutter/material.dart';

/// Animated night sky background with twinkling stars and a shooting star.
/// Used as the background when dark mode is enabled.
class NightSkyBackground extends StatefulWidget {
  final Widget child;
  const NightSkyBackground({super.key, required this.child});

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with TickerProviderStateMixin {
  late AnimationController _shootingStarController;
  late Animation<double> _shootingStarProgress;

  // Fixed star positions (generated once)
  final List<_Star> _stars = _generateStars(80);

  // Twinkling controller
  late AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();

    // Shooting star: repeats every 4 seconds with a 1s pause
    _shootingStarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(period: const Duration(seconds: 4));

    _shootingStarProgress = CurvedAnimation(
      parent: _shootingStarController,
      curve: Curves.easeIn,
    );

    // Twinkle: slow pulse
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shootingStarController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  static List<_Star> _generateStars(int count) {
    final rng = Random(42); // fixed seed for consistent layout
    return List.generate(count, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.7, // keep stars in upper 70%
        radius: rng.nextDouble() * 1.5 + 0.5,
        twinkleOffset: rng.nextDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Night sky gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0a0a2e), // deep navy
                Color(0xFF0d1b4b), // midnight blue
                Color(0xFF1a1a3e), // dark indigo
              ],
            ),
          ),
        ),

        // Stars
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarsPainter(
                stars: _stars,
                twinkle: _twinkleController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Shooting star
        AnimatedBuilder(
          animation: _shootingStarProgress,
          builder: (context, _) {
            return CustomPaint(
              painter: _ShootingStarPainter(
                progress: _shootingStarProgress.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // App content on top
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double twinkleOffset;
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleOffset,
  });
}

class _StarsPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinkle;

  const _StarsPainter({required this.stars, required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final opacity =
          0.4 + 0.6 * ((sin((twinkle + star.twinkleOffset) * pi)).abs());
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.twinkle != twinkle;
}

class _ShootingStarPainter extends CustomPainter {
  final double progress;

  const _ShootingStarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    // Shooting star travels from top-left area diagonally to bottom-right
    const startX = 0.1;
    const startY = 0.05;
    const endX = 0.55;
    const endY = 0.35;

    final currentX = (startX + (endX - startX) * progress) * size.width;
    final currentY = (startY + (endY - startY) * progress) * size.height;

    // Tail length
    const tailLength = 0.12;
    final tailX = (startX + (endX - startX) * (progress - tailLength).clamp(0.0, 1.0)) * size.width;
    final tailY = (startY + (endY - startY) * (progress - tailLength).clamp(0.0, 1.0)) * size.height;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.9),
        ],
      ).createShader(Rect.fromPoints(
        Offset(tailX, tailY),
        Offset(currentX, currentY),
      ))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(tailX, tailY), Offset(currentX, currentY), paint);

    // Bright head
    canvas.drawCircle(
      Offset(currentX, currentY),
      2.5,
      Paint()..color = Colors.white.withOpacity(0.95),
    );
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) => old.progress != progress;
}
