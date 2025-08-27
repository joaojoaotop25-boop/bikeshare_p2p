import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UnlockConfirmationDialogWidget extends StatelessWidget {
  final Map<String, dynamic> bikeData;
  final VoidCallback onStartRide;
  final VoidCallback onCancel;

  const UnlockConfirmationDialogWidget({
    Key? key,
    required this.bikeData,
    required this.onStartRide,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 85.w,
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.getSuccessColor(true),
                  size: 8.w,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              'Bicicleta Desbloqueada!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getSuccessColor(true),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Bike image
            Container(
              width: 20.w,
              height: 15.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: CustomImageWidget(
                  imageUrl: (bikeData["image"] as String?) ??
                      "https://images.pexels.com/photos/100582/pexels-photo-100582.jpeg",
                  width: 20.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Bike details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Modelo',
                    (bikeData["model"] as String?) ?? "Bike Urbana",
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                    'ID da Bicicleta',
                    (bikeData["id"] as String?) ?? "BK001",
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                    'Localização',
                    (bikeData["location"] as String?) ?? "Centro da Cidade",
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                    'Início do Aluguel',
                    _formatCurrentTime(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStartRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'directions_bike',
                          color: Colors.white,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Iniciar Pedalada',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} às ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}
