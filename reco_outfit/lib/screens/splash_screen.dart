import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    _rotationController.repeat();
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6750A4),
              Color(0xFF7C4DFF),
              Color(0xFF9C27B0),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background decoration circles
                  Positioned(
                    top: -MediaQuery.of(context).size.width * 0.25,
                    right: -MediaQuery.of(context).size.width * 0.25,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: -MediaQuery.of(context).size.width * 0.4,
                    left: -MediaQuery.of(context).size.width * 0.4,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.3,
                            constraints: const BoxConstraints(
                              minWidth: 80,
                              maxWidth: 140,
                              minHeight: 80,
                              maxHeight: 140,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.checkroom_rounded,
                              size: MediaQuery.of(context).size.width * 0.15,
                              color: const Color(0xFF6750A4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App Name
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  'StyleSense',
                                  style: GoogleFonts.inter(
                                    fontSize: MediaQuery.of(context).size.width * 0.08,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'AI-Powered Digital Wardrobe',
                                  style: GoogleFonts.inter(
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading indicator
                        Opacity(
                          opacity: _fadeAnimation.value * 0.8,
                          child: Column(
                            children: [
                              RotationTransition(
                                turns: _rotationController,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.1,
                                  height: MediaQuery.of(context).size.width * 0.1,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                'Preparing your wardrobe...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom branding
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _fadeAnimation.value * 0.6,
                      child: Column(
                        children: [
                          Text(
                            'Powered by AI',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Smart • Stylish • Simple',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
