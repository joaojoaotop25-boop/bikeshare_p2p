import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationChanged;
  final Map<String, dynamic> initialLocation;

  const LocationWidget({
    Key? key,
    required this.onLocationChanged,
    this.initialLocation = const {},
  }) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation =
      const LatLng(-23.5505, -46.6333); // São Paulo default
  final TextEditingController _addressController = TextEditingController();
  bool _isLoadingLocation = false;
  String _locationDescription = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeLocation() {
    if (widget.initialLocation.isNotEmpty) {
      _selectedLocation = LatLng(
        widget.initialLocation['latitude'] ?? -23.5505,
        widget.initialLocation['longitude'] ?? -46.6333,
      );
      _addressController.text = widget.initialLocation['address'] ?? '';
      _locationDescription = widget.initialLocation['description'] ?? '';
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Serviços de localização desabilitados');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Permissão de localização negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Permissão de localização negada permanentemente');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      _updateLocationInfo();

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_selectedLocation),
        );
      }
    } catch (e) {
      _showLocationError('Erro ao obter localização atual');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateLocationInfo();
  }

  void _updateLocationInfo() {
    // Simulate reverse geocoding for demo purposes
    _locationDescription =
        'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, '
        'Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}';

    final locationData = {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': _addressController.text,
      'description': _locationDescription,
    };

    widget.onLocationChanged(locationData);
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
                iconName: 'location_on',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Localização da Bicicleta',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Address Input
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Endereço de Retirada *',
              hintText: 'Ex: Rua das Flores, 123 - Centro',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'home',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),
            maxLines: 2,
            onChanged: (value) => _updateLocationInfo(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Endereço é obrigatório';
              }
              if (value.trim().length < 10) {
                return 'Digite um endereço mais completo';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Map Preview
          Container(
            height: 30.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: 15.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    onTap: _onMapTap,
                    markers: {
                      Marker(
                        markerId: const MarkerId('bike_location'),
                        position: _selectedLocation,
                        draggable: true,
                        onDragEnd: (LatLng location) {
                          setState(() {
                            _selectedLocation = location;
                          });
                          _updateLocationInfo();
                        },
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                        infoWindow: const InfoWindow(
                          title: 'Local da Bicicleta',
                          snippet: 'Arraste para ajustar a posição',
                        ),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),

                  // Loading overlay
                  if (_isLoadingLocation)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Control buttons
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          onPressed: _getCurrentLocation,
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.surface,
                          child: _isLoadingLocation
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.lightTheme.primaryColor,
                                  ),
                                )
                              : CustomIconWidget(
                                  iconName: 'my_location',
                                  color: AppTheme.lightTheme.primaryColor,
                                  size: 20,
                                ),
                        ),
                        SizedBox(height: 1.h),
                        FloatingActionButton.small(
                          onPressed: () {
                            if (_mapController != null) {
                              _mapController!.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            }
                          },
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.surface,
                          child: CustomIconWidget(
                            iconName: 'add',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        FloatingActionButton.small(
                          onPressed: () {
                            if (_mapController != null) {
                              _mapController!.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            }
                          },
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.surface,
                          child: CustomIconWidget(
                            iconName: 'remove',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Location Info
          if (_locationDescription.isNotEmpty)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _locationDescription,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 2.h),

          // Location Tips
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
                      'Dicas de Localização',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Toque no mapa para ajustar a posição exata\n'
                  '• Arraste o marcador para posicionamento preciso\n'
                  '• Use o botão de localização atual para facilitar\n'
                  '• Seja específico no endereço para facilitar a retirada',
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
