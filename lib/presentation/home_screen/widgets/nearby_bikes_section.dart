import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NearbyBikesSection extends StatelessWidget {
  const NearbyBikesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> nearbyBikes = [
      {
        "id": 1,
        "title": "Bike Urbana Comfort",
        "image":
            "https://images.pexels.com/photos/100582/pexels-photo-100582.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "distance": 0.3,
        "pricePerHour": "R\$ 8,50",
        "rating": 4.8,
        "isAvailable": true,
        "ownerName": "Carlos Silva"
      },
      {
        "id": 2,
        "title": "Mountain Bike Pro",
        "image":
            "https://images.pexels.com/photos/544966/pexels-photo-544966.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "distance": 0.7,
        "pricePerHour": "R\$ 12,00",
        "rating": 4.9,
        "isAvailable": true,
        "ownerName": "Ana Costa"
      },
      {
        "id": 3,
        "title": "Bike Elétrica City",
        "image":
            "https://images.pixabay.com/photo/2016/11/29/02/05/bicycle-1867229_1280.jpg",
        "distance": 1.2,
        "pricePerHour": "R\$ 15,00",
        "rating": 4.7,
        "isAvailable": true,
        "ownerName": "João Santos"
      },
      {
        "id": 4,
        "title": "Bike Vintage Retrô",
        "image":
            "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
        "distance": 1.8,
        "pricePerHour": "R\$ 10,00",
        "rating": 4.6,
        "isAvailable": false,
        "ownerName": "Maria Oliveira"
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
                'Bikes Próximas',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to browse screen
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
        SizedBox(
          height: 28.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: nearbyBikes.length,
            itemBuilder: (context, index) {
              final bike = nearbyBikes[index];
              final bool isAvailable = bike["isAvailable"] as bool;

              return Container(
                width: 70.w,
                margin: EdgeInsets.only(right: 3.w),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CustomImageWidget(
                              imageUrl: bike["image"] as String,
                              width: double.infinity,
                              height: 15.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (!isAvailable)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Indisponível',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 1.h,
                            right: 2.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'star',
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    bike["rating"].toString(),
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bike["title"] as String,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'location_on',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${bike["distance"]} km',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    bike["pricePerHour"] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '/hora',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isAvailable
                                      ? () {
                                          // Handle bike reservation
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAvailable
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : Colors.grey,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 1.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Reservar' : 'Indisponível',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
