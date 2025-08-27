import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@bikeshare.com': 'admin123',
    'user@bikeshare.com': 'user123',
    'owner@bikeshare.com': 'owner123',
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Check mock credentials
    if (_mockCredentials.containsKey(email) &&
        _mockCredentials[email] == password) {
      // Success - provide haptic feedback
      HapticFeedback.lightImpact();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login realizado com sucesso!'),
            backgroundColor: AppTheme.getSuccessColor(true),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to home screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home-screen');
        }
      }
    } else {
      // Error - show specific error message
      if (mounted) {
        String errorMessage = 'Email ou senha incorretos';

        if (!_mockCredentials.containsKey(email)) {
          errorMessage = 'Usuário não encontrado';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.getErrorColor(true),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegistration() {
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 6.h),

                    // App Logo Section
                    const AppLogoWidget(),

                    SizedBox(height: 6.h),

                    // Welcome Text
                    Text(
                      'Bem-vindo de volta!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Entre na sua conta para continuar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                    ),

                    SizedBox(height: 4.h),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h),

                    // Social Login Options
                    SocialLoginWidget(
                      isLoading: _isLoading,
                    ),

                    const Spacer(),

                    SizedBox(height: 4.h),

                    // Registration Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Novo usuário? ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        GestureDetector(
                          onTap: _isLoading ? null : _navigateToRegistration,
                          child: Text(
                            'Cadastre-se',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      AppTheme.lightTheme.primaryColor,
                                ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
