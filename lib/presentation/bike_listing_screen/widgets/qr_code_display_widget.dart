import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QrCodeDisplayWidget extends StatelessWidget {
  final String bikeId;
  final VoidCallback? onDownload;
  final VoidCallback? onPrint;

  const QrCodeDisplayWidget({
    Key? key,
    required this.bikeId,
    this.onDownload,
    this.onPrint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'qr_code',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'QR Code da Bicicleta',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // QR Code Container
          Container(
            width: 60.w,
            height: 60.w,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Simulated QR Code Pattern
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: QrCodePainter(),
                    size: Size(40.w, 40.w),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'ID: $bikeId',
                  style: AppTheme.dataTextStyle(
                    isLight: true,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: CustomIconWidget(
                    iconName: 'download',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 18,
                  ),
                  label: Text('Baixar'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrint,
                  icon: CustomIconWidget(
                    iconName: 'print',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 18,
                  ),
                  label: Text('Imprimir'),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Instructions
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Como usar o QR Code',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Cole o QR Code na sua bicicleta em local visível\n'
                  '• Locatários escaneiam o código para desbloquear\n'
                  '• Mantenha o código limpo e sem danos\n'
                  '• Substitua se necessário - você pode reimprimir',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Create a simple QR code-like pattern
    final cellSize = size.width / 21; // 21x21 grid like real QR codes

    // Draw white background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = Colors.black;

    // Draw finder patterns (corners)
    _drawFinderPattern(canvas, paint, Offset(0, 0), cellSize);
    _drawFinderPattern(
        canvas, paint, Offset(size.width - 7 * cellSize, 0), cellSize);
    _drawFinderPattern(
        canvas, paint, Offset(0, size.height - 7 * cellSize), cellSize);

    // Draw some random data pattern
    for (int i = 0; i < 21; i++) {
      for (int j = 0; j < 21; j++) {
        // Skip finder pattern areas
        if (_isInFinderPattern(i, j)) continue;

        // Create pseudo-random pattern based on position
        if ((i + j) % 3 == 0 || (i * j) % 7 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(
      Canvas canvas, Paint paint, Offset offset, double cellSize) {
    // Outer square (7x7)
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, 7 * cellSize, 7 * cellSize),
      paint,
    );

    // Inner white square (5x5)
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + cellSize,
        offset.dy + cellSize,
        5 * cellSize,
        5 * cellSize,
      ),
      paint,
    );

    // Center black square (3x3)
    paint.color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + 2 * cellSize,
        offset.dy + 2 * cellSize,
        3 * cellSize,
        3 * cellSize,
      ),
      paint,
    );
  }

  bool _isInFinderPattern(int i, int j) {
    // Top-left finder pattern
    if (i < 9 && j < 9) return true;
    // Top-right finder pattern
    if (i >= 12 && j < 9) return true;
    // Bottom-left finder pattern
    if (i < 9 && j >= 12) return true;
    return false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
