import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:u_go/modules/booking_module/screens/onboarding/views/welcome_sceen.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/home_screen.dart';
import 'package:u_go/app/core/utils/colors.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Petit délai esthétique
    await Future.delayed(const Duration(milliseconds: 1200));

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user == null) {
      _goTo(const WelcomeScreen());
      return;
    }

    final Widget destination = await _resolveDestinationByRole();
    if (!mounted) return;
    _goTo(destination);
  }

  Future<Widget> _resolveDestinationByRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role'); // 'driver' | 'passenger' | null
      if (role == 'driver') return const DriverHomeScreen();
      return const HomeScreen();
    } catch (_) {
      return const HomeScreen();
    }
  }

  void _goTo(Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(), // espace en haut
              // Logo centré
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    "assets/images/U-GO.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Loader 3 points animé bien en bas
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ThreeDotsLoader(color: mainColor, size: 10, gap: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loader trois points "bouncing" sans package externe.
/// - [color] : couleur des points (mainColor recommandé)
/// - [size]  : diamètre de chaque point
/// - [gap]   : espace horizontal entre les points
class ThreeDotsLoader extends StatefulWidget {
  final Color color;
  final double size;
  final double gap;

  const ThreeDotsLoader({
    super.key,
    required this.color,
    this.size = 10,
    this.gap = 8,
  });

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    // Un cycle complet = 1.2s, boucle infinie
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Trois intervalles décalés pour l'effet "..." en séquence
    _scales = [
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.60, curve: Curves.easeInOut),
      ),
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.80, curve: Curves.easeInOut),
      ),
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 1.00, curve: Curves.easeInOut),
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> anim) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.0).animate(anim),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.35),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(_scales[0]),
        SizedBox(width: widget.gap),
        _buildDot(_scales[1]),
        SizedBox(width: widget.gap),
        _buildDot(_scales[2]),
      ],
    );
  }
}
