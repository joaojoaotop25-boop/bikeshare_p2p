import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsAcceptanceWidget extends StatelessWidget {
  final bool isAccepted;
  final Function(bool?) onChanged;

  const TermsAcceptanceWidget({
    Key? key,
    required this.isAccepted,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: Checkbox(
            value: isAccepted,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!isAccepted),
            child: RichText(
              text: TextSpan(
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Eu concordo com os ',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: TextStyle(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' e ',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: TextStyle(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' do BikeShare P2P.',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
