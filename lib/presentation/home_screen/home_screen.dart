import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../models/bike_listing.dart';
import '../../models/category.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/bike_service.dart';
import './widgets/bike_card_widget.dart';
import './widgets/category_chips_widget.dart';
import './widgets/floating_map_button_widget.dart';
import './widgets/modern_search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BikeService _bikeService = BikeService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<BikeListing> _bikes = [];
  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String _currentLocation = 'Rio de Janeiro, Brasil';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final List<Future> futures = [
        _bikeService.getNearbyBikes(),
        _bikeService.getCategories(),
      ];

      final results = await Future.wait(futures);

      setState(() {
        _bikes = results[0] as List<BikeListing>;
        _categories = results[1] as List<Category>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _searchBikes(String query) async {
    if (query.trim().isEmpty && _selectedCategoryId == null) {
      _loadData();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bikes = await _bikeService.searchBikes(
        query: query.trim().isEmpty ? null : query.trim(),
        categoryId: _selectedCategoryId,
      );

      setState(() {
        _bikes = bikes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na busca: $e')),
        );
      }
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _searchBikes(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with location and profile
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with location and profile
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Localização atual',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _currentLocation,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Settings/Profile button
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.settingsScreen),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Modern Search Bar
                  ModernSearchBarWidget(
                    controller: _searchController,
                    onSearch: _searchBikes,
                    onFilterTap: () {
                      // TODO: Implement filter bottom sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filtros em breve!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Category chips
            if (_categories.isNotEmpty)
              Container(
                color: Colors.white,
                child: CategoryChipsWidget(
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: _onCategorySelected,
                ),
              ),

            const SizedBox(height: 8),

            // Bikes list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bikes.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _bikes.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: BikeCardWidget(
                                  bike: _bikes[index],
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.bikeDetailsScreen,
                                      arguments: _bikes[index].id,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Floating Map Button
      floatingActionButton: FloatingMapButtonWidget(
        onTap: () => Navigator.pushNamed(context, AppRoutes.mapScreen),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bike_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma bicicleta encontrada',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar sua busca ou localização',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Atualizar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
