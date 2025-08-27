import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BikeDetailsWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDetailsChanged;
  final Map<String, dynamic> initialDetails;

  const BikeDetailsWidget({
    Key? key,
    required this.onDetailsChanged,
    this.initialDetails = const {},
  }) : super(key: key);

  @override
  State<BikeDetailsWidget> createState() => _BikeDetailsWidgetState();
}

class _BikeDetailsWidgetState extends State<BikeDetailsWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'urbana';
  int _conditionRating = 5;

  final List<Map<String, String>> _categories = [
    {'value': 'urbana', 'label': 'Urbana'},
    {'value': 'eletrica', 'label': 'Elétrica'},
    {'value': 'mountain', 'label': 'Mountain Bike'},
    {'value': 'speed', 'label': 'Speed/Road'},
    {'value': 'bmx', 'label': 'BMX'},
    {'value': 'dobravel', 'label': 'Dobrável'},
    {'value': 'infantil', 'label': 'Infantil'},
    {'value': 'outros', 'label': 'Outros'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.initialDetails['title'] ?? '';
    _descriptionController.text = widget.initialDetails['description'] ?? '';
    _selectedCategory = widget.initialDetails['category'] ?? 'urbana';
    _conditionRating = widget.initialDetails['condition'] ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDetails() {
    final details = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'condition': _conditionRating,
    };
    widget.onDetailsChanged(details);
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
                iconName: 'directions_bike',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Detalhes da Bicicleta',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Título do Anúncio *',
              hintText: 'Ex: Bicicleta Speed Caloi 21 marchas',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'title',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),
            maxLength: 60,
            onChanged: (value) => _updateDetails(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Título é obrigatório';
              }
              if (value.trim().length < 10) {
                return 'Título deve ter pelo menos 10 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Descrição *',
              hintText:
                  'Descreva sua bicicleta: estado, características especiais, acessórios inclusos...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'description',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
            onChanged: (value) => _updateDetails(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Descrição é obrigatória';
              }
              if (value.trim().length < 20) {
                return 'Descrição deve ter pelo menos 20 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Category Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Categoria *',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'category',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['value'],
                child: Text(category['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
                _updateDetails();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecione uma categoria';
              }
              return null;
            },
          ),
          SizedBox(height: 4.h),

          // Condition Rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Estado da Bicicleta *',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _conditionRating = index + 1;
                            });
                            _updateDetails();
                          },
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            child: CustomIconWidget(
                              iconName: index < _conditionRating
                                  ? 'star'
                                  : 'star_border',
                              color: index < _conditionRating
                                  ? Colors.amber
                                  : Colors.grey[400]!,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _getConditionText(_conditionRating),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _getConditionColor(_conditionRating),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _getConditionDescription(_conditionRating),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getConditionText(int rating) {
    switch (rating) {
      case 1:
        return 'Precisa de Reparos';
      case 2:
        return 'Estado Regular';
      case 3:
        return 'Bom Estado';
      case 4:
        return 'Muito Bom Estado';
      case 5:
        return 'Excelente Estado';
      default:
        return 'Excelente Estado';
    }
  }

  Color _getConditionColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  String _getConditionDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Bicicleta com problemas mecânicos ou estéticos que precisam ser reparados';
      case 2:
        return 'Bicicleta funcional mas com alguns sinais de uso e pequenos problemas';
      case 3:
        return 'Bicicleta em condições normais de uso com sinais leves de desgaste';
      case 4:
        return 'Bicicleta bem conservada com poucos sinais de uso';
      case 5:
        return 'Bicicleta como nova ou muito bem conservada';
      default:
        return 'Bicicleta como nova ou muito bem conservada';
    }
  }
}
