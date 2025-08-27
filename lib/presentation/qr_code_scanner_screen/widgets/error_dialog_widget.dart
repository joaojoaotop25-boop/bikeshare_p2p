import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ErrorDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const ErrorDialogWidget({
    Key? key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 85.w,
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: AppTheme.getErrorColor(true).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.getErrorColor(true),
                  size: 8.w,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getErrorColor(true),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Message
            Text(
              message,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Action buttons
            Row(
              children: [
                if (actionText != null && onAction != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        actionText!,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'OK',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
