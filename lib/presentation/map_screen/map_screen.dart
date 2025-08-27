import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/bike_listing.dart';
import '../../services/bike_service.dart';
import '../../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final BikeService _bikeService = BikeService();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-22.9068, -43.1729), // Rio de Janeiro
    zoom: 12.0,
  );

  Set<Marker> _markers = {};
  List<BikeListing> _bikes = [];
  bool _isLoading = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadBikesAndCreateMarkers();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      // Move camera to user location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _loadBikesAndCreateMarkers() async {
    setState(() => _isLoading = true);

    try {
      final bikes = await _bikeService.getNearbyBikes(limit: 50);

      final markers = bikes.map((bike) {
        return Marker(
          markerId: MarkerId(bike.id),
          position: LatLng(bike.latitude, bike.longitude),
          infoWindow: InfoWindow(
            title: bike.title,
            snippet: 'R\$ ${bike.pricePerHour.toStringAsFixed(0)}/hora',
            onTap: () => _showBikeDetails(bike),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      }).toSet();

      // Add user location marker if available
      if (_currentPosition != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: 'Minha Localização'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }

      setState(() {
        _bikes = bikes;
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar bicicletas: $e')),
        );
      }
    }
  }

  void _showBikeDetails(BikeListing bike) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBikeDetailsModal(bike),
    );
  }

  Widget _buildBikeDetailsModal(BikeListing bike) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bike image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      bike.primaryImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.directions_bike,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title and location
                Text(
                  bike.title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${bike.city}, ${bike.country}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating
                if (bike.rating > 0)
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${bike.rating.toStringAsFixed(1)} (${bike.reviewCount} avaliações)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Price and button
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'R\$ ${bike.pricePerHour.toStringAsFixed(0)}/hora',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (bike.pricePerDay != null)
                          Text(
                            'R\$ ${bike.pricePerDay!.toStringAsFixed(0)}/dia',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.bikeDetailsScreen,
                          arguments: bike.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ver Detalhes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Bicicletas',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.black),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadBikesAndCreateMarkers,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withAlpha(179),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Bike count indicator
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bike,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_bikes.length} bicicletas disponíveis',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
