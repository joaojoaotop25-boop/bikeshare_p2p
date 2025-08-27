import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/category.dart';

class CategoryChipsWidget extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryChipsWidget({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All categories chip
          _buildCategoryChip(
            context: context,
            label: 'Todas',
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
            iconUrl: null,
          ),

          const SizedBox(width: 12),

          // Category chips
          ...categories
              .map((category) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCategoryChip(
                      context: context,
                      label: category.name,
                      isSelected: selectedCategoryId == category.id,
                      onTap: () => onCategorySelected(category.id),
                      iconUrl: category.iconUrl,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? iconUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: iconUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.directions_bike,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
