import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UserTypeSelectorWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const UserTypeSelectorWidget({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Usuário',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged('renter'),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: selectedType == 'renter'
                          ? AppTheme.lightTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'directions_bike',
                          color: selectedType == 'renter'
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Locatário',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: selectedType == 'renter'
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged('owner'),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: selectedType == 'owner'
                          ? AppTheme.lightTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: selectedType == 'owner'
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Proprietário',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: selectedType == 'owner'
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
