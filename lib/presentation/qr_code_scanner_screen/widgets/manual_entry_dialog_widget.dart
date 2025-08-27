import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ManualEntryDialogWidget extends StatefulWidget {
  final Function(String) onCodeSubmitted;

  const ManualEntryDialogWidget({
    Key? key,
    required this.onCodeSubmitted,
  }) : super(key: key);

  @override
  State<ManualEntryDialogWidget> createState() =>
      _ManualEntryDialogWidgetState();
}

class _ManualEntryDialogWidgetState extends State<ManualEntryDialogWidget> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Auto focus on the text field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });
      widget.onCodeSubmitted(code);
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inserir Código',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.grey[600]!,
                        size: 4.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Description
            Text(
              'Digite o código QR manualmente caso não seja possível escaneá-lo.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: 13.sp,
              ),
            ),

            SizedBox(height: 3.h),

            // Input field
            TextField(
              controller: _codeController,
              focusNode: _focusNode,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: 'Código QR',
                hintText: 'Digite o código aqui...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'qr_code',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _submitCode(),
            ),

            SizedBox(height: 4.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
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
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
                    onPressed: _isSubmitting ? null : _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : Text(
                            'Confirmar',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
}
