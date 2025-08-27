import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final Color accentColor;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Expanded(
              flex: 3,
              child: Container(
                width: 80.w,
                height: 35.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 80.w,
                    height: 35.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            SizedBox(height: 6.h),

            // Content
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Title
                  Text(
                    title,
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 3.h),

                  // Description
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
