import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    required this.isLoading,
  }) : super(key: key);

  void _handleGoogleLogin(BuildContext context) {
    if (isLoading) return;

    // Mock Google login implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Google em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleFacebookLogin(BuildContext context) {
    if (isLoading) return;

    // Mock Facebook login implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Facebook em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "ou" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'ou',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Google Login Button
        SizedBox(
          height: 6.h,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => _handleGoogleLogin(context),
            icon: CustomImageWidget(
              imageUrl:
                  'https://developers.google.com/identity/images/g-logo.png',
              width: 5.w,
              height: 5.w,
              fit: BoxFit.contain,
            ),
            label: Text(
              'Continuar com Google',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Facebook Login Button
        SizedBox(
          height: 6.h,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => _handleFacebookLogin(context),
            icon: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: 'facebook',
                color: Colors.white,
                size: 3.w,
              ),
            ),
            label: Text(
              'Continuar com Facebook',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
