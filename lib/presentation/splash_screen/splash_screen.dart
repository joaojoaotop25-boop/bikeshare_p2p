import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Check if user is authenticated
      if (_authService.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bike animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.network(
                'https://lottie.host/4f1c1e5c-8a2b-4f23-9c5d-2e8f7a9b0c1d/cycle.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_bike,
                    size: 80,
                    color: Colors.white,
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            // App name
            Text(
              'BikeShare',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Tagline
            Text(
              'Ride the City, Share the Joy',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 60),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
