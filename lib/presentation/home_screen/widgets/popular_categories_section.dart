import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PopularCategoriesSection extends StatelessWidget {
  const PopularCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        "id": 1,
        "name": "Urbana",
        "icon": "directions_bike",
        "color": AppTheme.lightTheme.colorScheme.primary,
        "count": 45
      },
      {
        "id": 2,
        "name": "Elétrica",
        "icon": "electric_bike",
        "color": Colors.green,
        "count": 23
      },
      {
        "id": 3,
        "name": "Mountain",
        "icon": "terrain",
        "color": Colors.orange,
        "count": 18
      },
      {
        "id": 4,
        "name": "Speed",
        "icon": "speed",
        "color": Colors.red,
        "count": 12
      },
      {
        "id": 5,
        "name": "Vintage",
        "icon": "history",
        "color": Colors.purple,
        "count": 8
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Categorias Populares',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final Color categoryColor = category["color"] as Color;

              return Container(
                width: 20.w,
                margin: EdgeInsets.only(right: 3.w),
                child: InkWell(
                  onTap: () {
                    // Handle category selection
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: category["icon"] as String,
                            color: categoryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          category["name"] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${category["count"]} bikes',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
