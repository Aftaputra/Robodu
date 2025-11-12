import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/route.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Navigate to home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoute.home);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // teal background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Robot Icon
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: RobotIconPainter(),
                ),
              ),
              const SizedBox(height: 40),
              // App Name
              const Text(
                'Robo-du',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RobotIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E6F6E) // dark teal color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Main body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 60, height: 50),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paint);

    // Head antenna
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 35),
          width: 8,
          height: 15,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - 40, center.dy),
          width: 12,
          height: 30,
        ),
        const Radius.circular(6),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 40, center.dy),
          width: 12,
          height: 30,
        ),
        const Radius.circular(6),
      ),
      paint,
    );

    // Eyes & Mouth (lighter shade for contrast)
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Eyes
    canvas.drawCircle(Offset(center.dx - 12, center.dy - 8), 4, detailPaint);
    canvas.drawCircle(Offset(center.dx + 12, center.dy - 8), 4, detailPaint);

    // Mouth dots
    canvas.drawCircle(Offset(center.dx - 8, center.dy + 8), 2, detailPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 8), 2, detailPaint);
    canvas.drawCircle(Offset(center.dx + 8, center.dy + 8), 2, detailPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
