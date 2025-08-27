import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/map_screen/map_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/bike_listing_screen/bike_listing_screen.dart';
import '../presentation/qr_code_scanner_screen/qr_code_scanner_screen.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String onboardingFlow = '/onboarding';
  static const String loginScreen = '/login';
  static const String registrationScreen = '/registration';
  static const String homeScreen = '/home';
  static const String mapScreen = '/map';
  static const String settingsScreen = '/settings';
  static const String bikeListing = '/bike-listing';
  static const String bikeDetailsScreen = '/bike-details';
  static const String qrCodeScannerScreen = '/qr-scanner';
  static const String myBikesScreen = '/my-bikes';
  static const String myRentalsScreen = '/my-rentals';
  static const String profileScreen = '/profile';
  static const String favoritesScreen = '/favorites';
  static const String supportScreen = '/support';
  static const String privacyScreen = '/privacy';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboardingFlow:
        return MaterialPageRoute(builder: (_) => const OnboardingFlow());
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registrationScreen:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case mapScreen:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case bikeListing:
        return MaterialPageRoute(builder: (_) => const BikeListingScreen());
      case qrCodeScannerScreen:
        return MaterialPageRoute(builder: (_) => const QrCodeScannerScreen());
      case bikeDetailsScreen:
        final bikeId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen(
              title: 'Detalhes da Bicicleta',
              subtitle: 'Bike ID: ${bikeId ?? 'N/A'}'),
        );
      case myBikesScreen:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
              title: 'Minhas Bicicletas', subtitle: 'Gerencie seus anúncios'),
        );
      case myRentalsScreen:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
              title: 'Meus Aluguéis', subtitle: 'Histórico de aluguéis'),
        );
      case profileScreen:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
              title: 'Perfil', subtitle: 'Edite suas informações'),
        );
      case favoritesScreen:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
              title: 'Favoritos', subtitle: 'Suas bicicletas favoritas'),
        );
      case supportScreen:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
              title: 'Suporte', subtitle: 'Central de ajuda'),
        );
      case privacyScreen:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
              title: 'Privacidade', subtitle: 'Política de privacidade'),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página não encontrada')),
            body: const Center(child: Text('404 - Página não encontrada')),
          ),
        );
    }
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta tela está em desenvolvimento',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
