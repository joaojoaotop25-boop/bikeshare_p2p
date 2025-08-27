import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScannerHeaderWidget extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onFlashlightToggle;
  final bool isFlashlightOn;
  final bool isFlashlightAvailable;

  const ScannerHeaderWidget({
    Key? key,
    required this.onBackPressed,
    required this.onFlashlightToggle,
    required this.isFlashlightOn,
    required this.isFlashlightAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2.h,
        left: 4.w,
        right: 4.w,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 5.w,
                ),
              ),
            ),
          ),

          // Title
          Text(
            'Escanear QR Code',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Flashlight toggle
          GestureDetector(
            onTap: isFlashlightAvailable ? onFlashlightToggle : null,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isFlashlightOn
                    ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFlashlightOn
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isFlashlightOn ? 'flash_on' : 'flash_off',
                  color: isFlashlightOn
                      ? Colors.white
                      : isFlashlightAvailable
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                  size: 5.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
