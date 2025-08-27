import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentReviewsSection extends StatelessWidget {
  const RecentReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recentReviews = [
      {
        "id": 1,
        "userName": "Pedro Almeida",
        "userAvatar":
            "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "rating": 5,
        "comment":
            "Excelente bike! Muito confortável para pedalar pela cidade. O dono foi super atencioso.",
        "bikeName": "Bike Urbana Comfort",
        "timestamp": "2 horas atrás"
      },
      {
        "id": 2,
        "userName": "Carla Mendes",
        "userAvatar":
            "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "rating": 4,
        "comment":
            "Ótima experiência! A bike estava em perfeito estado e o processo foi muito fácil.",
        "bikeName": "Mountain Bike Pro",
        "timestamp": "5 horas atrás"
      },
      {
        "id": 3,
        "userName": "Lucas Ferreira",
        "userAvatar":
            "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "rating": 5,
        "comment":
            "Bike elétrica incrível! Facilitou muito meu trajeto para o trabalho. Recomendo!",
        "bikeName": "Bike Elétrica City",
        "timestamp": "1 dia atrás"
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avaliações Recentes',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all reviews
                },
                child: Text(
                  'Ver todas',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: recentReviews.length,
          itemBuilder: (context, index) {
            final review = recentReviews[index];
            final int rating = review["rating"] as int;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CustomImageWidget(
                              imageUrl: review["userAvatar"] as String,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review["userName"] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return CustomIconWidget(
                                        iconName: starIndex < rating
                                            ? 'star'
                                            : 'star_border',
                                        color: starIndex < rating
                                            ? Colors.amber
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurfaceVariant,
                                        size: 16,
                                      );
                                    }),
                                    SizedBox(width: 2.w),
                                    Text(
                                      review["timestamp"] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        review["comment"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'directions_bike',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              review["bikeName"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
