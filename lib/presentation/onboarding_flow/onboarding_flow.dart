import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_bottom_widget.dart';
import './widgets/onboarding_page_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  bool _userInteracted = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Descubra Bicicletas\nPerto de Você",
      "description":
          "Encontre facilmente bicicletas disponíveis para aluguel no mapa interativo. Veja a localização em tempo real e escolha a bike perfeita para sua jornada.",
      "imageUrl":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "title": "Desbloqueie com\nCódigo QR",
      "description":
          "Simplesmente escaneie o código QR na bicicleta para desbloqueá-la instantaneamente. Processo rápido e seguro para começar sua viagem imediatamente.",
      "imageUrl":
          "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "title": "Comunidade e\nRenda Extra",
      "description":
          "Participe da nossa comunidade ativa, compartilhe experiências e ganhe dinheiro alugando sua própria bicicleta para outros usuários.",
      "imageUrl":
          "https://images.unsplash.com/photo-1571068316344-75bc76f77890?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_userInteracted && mounted) {
        if (_currentPage < _onboardingData.length - 1) {
          _nextPage();
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _pauseAutoAdvance() {
    setState(() {
      _userInteracted = true;
    });
    _autoAdvanceTimer?.cancel();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _pauseAutoAdvance();
    _completeOnboarding();
  }

  void _startApp() {
    HapticFeedback.mediumImpact();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home-screen');
      }
    } catch (e) {
      // Fallback navigation if SharedPreferences fails
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home-screen');
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _pauseAutoAdvance();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPageWidget(
                  title: data["title"] as String,
                  description: data["description"] as String,
                  imageUrl: data["imageUrl"] as String,
                  accentColor: AppTheme.lightTheme.primaryColor,
                );
              },
            ),
          ),

          // Bottom Navigation
          OnboardingBottomWidget(
            currentPage: _currentPage,
            totalPages: _onboardingData.length,
            onNext: _nextPage,
            onSkip: _skipOnboarding,
            onStart: _startApp,
          ),
        ],
      ),
    );
  }
}
