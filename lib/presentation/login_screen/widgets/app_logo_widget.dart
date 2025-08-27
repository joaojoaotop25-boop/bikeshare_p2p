import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container with Sky Blue Background
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: 'directions_bike',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 10.w,
          ),
        ),

        SizedBox(height: 2.h),

        // App Name
        Text(
          'BikeShare P2P',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),

        SizedBox(height: 0.5.h),

        // App Tagline
        Text(
          'Conecte-se, Pedale, Compartilhe',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
