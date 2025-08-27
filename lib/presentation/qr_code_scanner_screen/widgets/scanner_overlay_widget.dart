import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ScannerOverlayWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onManualEntry;

  const ScannerOverlayWidget({
    Key? key,
    required this.isScanning,
    this.onManualEntry,
  }) : super(key: key);

  @override
  State<ScannerOverlayWidget> createState() => _ScannerOverlayWidgetState();
}

class _ScannerOverlayWidgetState extends State<ScannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.6),
        ),

        // Scanning frame
        Center(
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Transparent center
                Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                // Animated corner highlights
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.lightTheme.primaryColor.withValues(
                              alpha: 0.3 + (0.7 * _animation.value),
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Corner indicators
                ...List.generate(4, (index) {
                  return Positioned(
                    top: index < 2 ? 0 : null,
                    bottom: index >= 2 ? 0 : null,
                    left: index % 2 == 0 ? 0 : null,
                    right: index % 2 == 1 ? 0 : null,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: index == 0
                              ? const Radius.circular(16)
                              : Radius.zero,
                          topRight: index == 1
                              ? const Radius.circular(16)
                              : Radius.zero,
                          bottomLeft: index == 2
                              ? const Radius.circular(16)
                              : Radius.zero,
                          bottomRight: index == 3
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Instruction text
        Positioned(
          bottom: 25.h,
          left: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Posicione o código QR dentro da moldura',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                if (widget.isScanning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Escaneando...',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // Manual entry option
        Positioned(
          bottom: 15.h,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: widget.onManualEntry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Inserir código manualmente',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontSize: 13.sp,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
