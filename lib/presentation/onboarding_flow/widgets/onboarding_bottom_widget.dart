import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class OnboardingBottomWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onStart;

  const OnboardingBottomWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = currentPage == totalPages - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                width: currentPage == index ? 8.w : 2.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip Button
              isLastPage
                  ? SizedBox(width: 20.w)
                  : TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.5.h),
                      ),
                      child: Text(
                        'Pular',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

              // Next/Start Button
              ElevatedButton(
                onPressed: isLastPage ? onStart : onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isLastPage ? 'Começar' : 'Próximo',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
