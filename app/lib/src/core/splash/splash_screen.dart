import 'package:flutter/material.dart';

/// Refined launch experience.
///
/// Fades in the app identity, holds briefly, then calls [onComplete].
/// Tests construct [KendoCompanionApp] directly and never render this widget.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  static const _gold = Color(0xFFC8A84A);
  static const _darkBg = Color(0xFF131210);
  static const _lightBg = Color(0xFFFFF8EE);
  static const _darkSubtle = Color(0xFFCBC4B7);
  static const _lightSubtle = Color(0xFF5A5248);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Fade in → hold → fade out.
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Respect the system's reduced-motion preference.
      if (MediaQuery.disableAnimationsOf(context)) {
        widget.onComplete();
        return;
      }
      _controller.forward().whenComplete(widget.onComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _darkBg : _lightBg,
      body: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Japanese kanji for kendo — calm gold accent.
              Text(
                '剣道',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  color: _gold,
                  letterSpacing: 14,
                  height: 1,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 40,
                child: Divider(
                  color: _gold.withAlpha(180),
                  thickness: 0.5,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Kendo Companion',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? _darkSubtle : _lightSubtle,
                  letterSpacing: 3.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
