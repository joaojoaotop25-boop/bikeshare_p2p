import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PricingWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onPricingChanged;
  final Map<String, dynamic> initialPricing;

  const PricingWidget({
    Key? key,
    required this.onPricingChanged,
    this.initialPricing = const {},
  }) : super(key: key);

  @override
  State<PricingWidget> createState() => _PricingWidgetState();
}

class _PricingWidgetState extends State<PricingWidget> {
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();
  final TextEditingController _weeklyRateController = TextEditingController();
  bool _enableDailyRate = false;
  bool _enableWeeklyRate = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _hourlyRateController.text =
        widget.initialPricing['hourlyRate']?.toString() ?? '';
    _dailyRateController.text =
        widget.initialPricing['dailyRate']?.toString() ?? '';
    _weeklyRateController.text =
        widget.initialPricing['weeklyRate']?.toString() ?? '';
    _enableDailyRate = widget.initialPricing['enableDailyRate'] ?? false;
    _enableWeeklyRate = widget.initialPricing['enableWeeklyRate'] ?? false;
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    _weeklyRateController.dispose();
    super.dispose();
  }

  void _updatePricing() {
    final pricing = {
      'hourlyRate': _parsePrice(_hourlyRateController.text),
      'dailyRate':
          _enableDailyRate ? _parsePrice(_dailyRateController.text) : null,
      'weeklyRate':
          _enableWeeklyRate ? _parsePrice(_weeklyRateController.text) : null,
      'enableDailyRate': _enableDailyRate,
      'enableWeeklyRate': _enableWeeklyRate,
    };
    widget.onPricingChanged(pricing);
  }

  double? _parsePrice(String text) {
    if (text.isEmpty) return null;
    final cleanText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    final normalizedText = cleanText.replaceAll(',', '.');
    return double.tryParse(normalizedText);
  }

  String _formatPrice(String value) {
    if (value.isEmpty) return value;

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.isEmpty) return '';

    final intValue = int.parse(cleanValue);
    final formattedValue = (intValue / 100).toStringAsFixed(2);
    return 'R\$ ${formattedValue.replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'attach_money',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Preços de Aluguel',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Hourly Rate (Required)
          TextFormField(
            controller: _hourlyRateController,
            decoration: InputDecoration(
              labelText: 'Preço por Hora *',
              hintText: 'R\$ 0,00',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
              suffixText: '/hora',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CurrencyInputFormatter(),
            ],
            onChanged: (value) => _updatePricing(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Preço por hora é obrigatório';
              }
              final price = _parsePrice(value);
              if (price == null || price <= 0) {
                return 'Digite um preço válido';
              }
              if (price < 1.0) {
                return 'Preço mínimo é R\$ 1,00';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Daily Rate Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Switch(
                      value: _enableDailyRate,
                      onChanged: (value) {
                        setState(() {
                          _enableDailyRate = value;
                          if (!value) {
                            _dailyRateController.clear();
                          }
                        });
                        _updatePricing();
                      },
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preço por Dia',
                            style: AppTheme.lightTheme.textTheme.titleSmall,
                          ),
                          Text(
                            'Ofereça desconto para aluguéis de dia inteiro',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_enableDailyRate) ...[
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _dailyRateController,
                    decoration: InputDecoration(
                      labelText: 'Preço por Dia',
                      hintText: 'R\$ 0,00',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomIconWidget(
                          iconName: 'today',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      suffixText: '/dia',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CurrencyInputFormatter(),
                    ],
                    onChanged: (value) => _updatePricing(),
                    validator: _enableDailyRate
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite o preço por dia';
                            }
                            final price = _parsePrice(value);
                            if (price == null || price <= 0) {
                              return 'Digite um preço válido';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Weekly Rate Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Switch(
                      value: _enableWeeklyRate,
                      onChanged: (value) {
                        setState(() {
                          _enableWeeklyRate = value;
                          if (!value) {
                            _weeklyRateController.clear();
                          }
                        });
                        _updatePricing();
                      },
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preço por Semana',
                            style: AppTheme.lightTheme.textTheme.titleSmall,
                          ),
                          Text(
                            'Ofereça desconto para aluguéis semanais',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_enableWeeklyRate) ...[
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _weeklyRateController,
                    decoration: InputDecoration(
                      labelText: 'Preço por Semana',
                      hintText: 'R\$ 0,00',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomIconWidget(
                          iconName: 'date_range',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      suffixText: '/semana',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CurrencyInputFormatter(),
                    ],
                    onChanged: (value) => _updatePricing(),
                    validator: _enableWeeklyRate
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite o preço por semana';
                            }
                            final price = _parsePrice(value);
                            if (price == null || price <= 0) {
                              return 'Digite um preço válido';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Pricing Tips
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
                      iconName: 'lightbulb',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Dicas de Preço',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Pesquise preços similares na sua região\n'
                  '• Considere o estado e categoria da bicicleta\n'
                  '• Preços por dia/semana atraem mais locatários\n'
                  '• Você pode ajustar os preços a qualquer momento',
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

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(newValue.text.replaceAll(RegExp(r'[^\d]'), ''));
    final String formatted =
        'R\$ ${(value / 100).toStringAsFixed(2).replaceAll('.', ',')}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
