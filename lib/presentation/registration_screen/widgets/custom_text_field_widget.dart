import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showVisibilityToggle;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool showValidationIcon;
  final VoidCallback? onChanged;

  const CustomTextFieldWidget({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.inputFormatters,
    this.suffixIcon,
    this.showValidationIcon = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _isObscured = true;
  String? _errorText;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    widget.controller.addListener(_validateField);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
        _isValid = error == null && widget.controller.text.isNotEmpty;
      });
    }
    if (widget.onChanged != null) {
      widget.onChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && _isObscured,
          inputFormatters: widget.inputFormatters,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: _buildSuffixIcon(),
            errorText: _errorText,
            errorMaxLines: 2,
          ),
          onChanged: (value) => _validateField(),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.showVisibilityToggle) {
      return IconButton(
        icon: CustomIconWidget(
          iconName: _isObscured ? 'visibility' : 'visibility_off',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    if (widget.showValidationIcon && widget.controller.text.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 3.w),
        child: CustomIconWidget(
          iconName: _isValid ? 'check_circle' : 'error',
          color: _isValid
              ? AppTheme.getSuccessColor(true)
              : AppTheme.lightTheme.colorScheme.error,
          size: 20,
        ),
      );
    }

    return widget.suffixIcon;
  }
}
