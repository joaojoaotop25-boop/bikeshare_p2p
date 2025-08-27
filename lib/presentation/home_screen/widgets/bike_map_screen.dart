import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BikeMapScreen extends StatefulWidget {
  const BikeMapScreen({super.key});

  @override
  State<BikeMapScreen> createState() => _BikeMapScreenState();
}

class _BikeMapScreenState extends State<BikeMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333), // São Paulo
    zoom: 14.0,
  );

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _createBikeMarkers();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _createBikeMarkers() {
    final bikeLocations = [
      {
        'id': 'bike_1',
        'title': 'Bike Urbana Comfort',
        'lat': -23.5505,
        'lng': -46.6333,
        'price': 'R\$ 8,50/h',
        'available': true,
      },
      {
        'id': 'bike_2',
        'title': 'Mountain Bike Pro',
        'lat': -23.5515,
        'lng': -46.6343,
        'price': 'R\$ 12,00/h',
        'available': true,
      },
      {
        'id': 'bike_3',
        'title': 'Bike Elétrica City',
        'lat': -23.5495,
        'lng': -46.6323,
        'price': 'R\$ 15,00/h',
        'available': true,
      },
      {
        'id': 'bike_4',
        'title': 'Bike Vintage Retrô',
        'lat': -23.5485,
        'lng': -46.6313,
        'price': 'R\$ 10,00/h',
        'available': false,
      },
      {
        'id': 'bike_5',
        'title': 'Bike Speed Racing',
        'lat': -23.5525,
        'lng': -46.6353,
        'price': 'R\$ 18,00/h',
        'available': true,
      },
    ];

    setState(() {
      _markers = bikeLocations.map((bike) {
        return Marker(
          markerId: MarkerId(bike['id'] as String),
          position: LatLng(bike['lat'] as double, bike['lng'] as double),
          infoWindow: InfoWindow(
            title: bike['title'] as String,
            snippet:
                '${bike['price']} • ${(bike['available'] as bool) ? "Disponível" : "Indisponível"}',
            onTap: () {
              _showBikeDetails(bike);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            (bike['available'] as bool)
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        );
      }).toSet();
    });
  }

  void _showBikeDetails(Map<String, dynamic> bike) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                bike['title'] as String,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: (bike['available'] as bool)
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (bike['available'] as bool)
                          ? 'Disponível'
                          : 'Indisponível',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: (bike['available'] as bool)
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    bike['price'] as String,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to directions
                      },
                      child: const Text('Direções'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (bike['available'] as bool)
                          ? () {
                              Navigator.pop(context);
                              // Handle bike reservation
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: Text(
                        (bike['available'] as bool)
                            ? 'Reservar'
                            : 'Indisponível',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            markers: _markers,
          ),

          // Search and filter bar
          Positioned(
            top: 2.h,
            left: 4.w,
            right: 4.w,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Procurar bikes próximas...',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'filter_list',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current location button
          Positioned(
            bottom: 12.h,
            right: 4.w,
            child: FloatingActionButton(
              mini: true,
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: _isLoadingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'my_location',
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
