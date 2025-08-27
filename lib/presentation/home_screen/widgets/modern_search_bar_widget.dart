import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernSearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onFilterTap;

  const ModernSearchBarWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSearch,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                hintText: 'Para onde vamos pedalar?',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Filter button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Icon(
                Icons.tune,
                color: Colors.grey[600],
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
