import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PasswordStrengthIndicatorWidget extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicatorWidget({
    Key? key,
    required this.password,
  }) : super(key: key);

  int _getPasswordStrength() {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  String _getStrengthText() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 0:
      case 1:
        return 'Muito fraca';
      case 2:
        return 'Fraca';
      case 3:
        return 'Média';
      case 4:
        return 'Forte';
      case 5:
        return 'Muito forte';
      default:
        return '';
    }
  }

  Color _getStrengthColor() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 0:
      case 1:
        return AppTheme.lightTheme.colorScheme.error;
      case 2:
        return AppTheme.getWarningColor(true);
      case 3:
        return AppTheme.getWarningColor(true);
      case 4:
        return AppTheme.getSuccessColor(true);
      case 5:
        return AppTheme.getSuccessColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return SizedBox.shrink();

    final strength = _getPasswordStrength();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.h),
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 0.5.h,
                margin: EdgeInsets.only(right: index < 4 ? 1.w : 0),
                decoration: BoxDecoration(
                  color: index < strength
                      ? _getStrengthColor()
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 0.5.h),
        Text(
          _getStrengthText(),
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: _getStrengthColor(),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
