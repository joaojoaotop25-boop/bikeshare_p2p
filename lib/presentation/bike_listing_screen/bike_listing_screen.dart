import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/category.dart';
import '../../models/bike_listing.dart';
import '../../services/bike_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class BikeListingScreen extends StatefulWidget {
  const BikeListingScreen({Key? key}) : super(key: key);

  @override
  State<BikeListingScreen> createState() => _BikeListingScreenState();
}

class _BikeListingScreenState extends State<BikeListingScreen> {
  final BikeService _bikeService = BikeService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Rio de Janeiro');
  final _countryController = TextEditingController(text: 'Brasil');
  final _rulesController = TextEditingController();

  List<Category> _categories = [];
  String? _selectedCategoryId;
  String _selectedBikeType = 'city';
  List<File> _selectedImages = [];
  List<String> _features = [];
  Position? _currentPosition;

  bool _isLoading = false;
  bool _isLoadingCategories = true;

  final List<String> _bikeTypes = [
    'city',
    'mountain',
    'electric',
    'hybrid',
    'road',
  ];

  final List<String> _availableFeatures = [
    'Capacete incluído',
    'Trava incluída',
    'Luzes LED',
    'Cesta',
    'GPS tracker',
    'Carregador USB',
    'Kit reparo',
    'Suporte garrafa água',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _bikeService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
          if (_selectedImages.length > 10) {
            _selectedImages = _selectedImages.take(10).toList();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagens: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Adicione pelo menos uma imagem da bicicleta')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Create bike listing
      final bikeListing = BikeListing(
        id: '',
        hostId: user.id,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: _selectedCategoryId,
        bikeType: _selectedBikeType,
        pricePerHour: double.parse(_pricePerHourController.text),
        pricePerDay: _pricePerDayController.text.isEmpty
            ? null
            : double.parse(_pricePerDayController.text),
        latitude: _currentPosition?.latitude ?? -22.9068,
        longitude: _currentPosition?.longitude ?? -43.1729,
        address: _addressController.text,
        city: _cityController.text,
        country: _countryController.text,
        status: 'pending',
        bikeStatus: 'available',
        isAvailable: true,
        minimumRentalHours: 1,
        maximumRentalHours: 24,
        features: _features,
        rules: _rulesController.text.isEmpty ? null : _rulesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: [],
      );

      final createdListing = await _bikeService.createBikeListing(bikeListing);

      // Upload images
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageUrl = await _bikeService.uploadBikeImage(
          createdListing.id,
          _selectedImages[i],
        );

        await _bikeService.addBikeImage(
          createdListing.id,
          imageUrl,
          isPrimary: i == 0,
        );
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Anúncio criado com sucesso! Aguarde aprovação.')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homeScreen,
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar anúncio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Anunciar Bicicleta',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adicione sua bicicleta',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Preencha as informações para começar a ganhar dinheiro',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Photo upload section
                    _buildSection(
                      title: 'Fotos da Bicicleta',
                      child: Column(
                        children: [
                          if (_selectedImages.isEmpty)
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey[300]!,
                                      style: BorderStyle.solid),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Adicionar Fotos',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Adicione até 10 fotos da sua bicicleta',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                Container(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == _selectedImages.length) {
                                        return GestureDetector(
                                          onTap: _selectedImages.length < 10
                                              ? _pickImages
                                              : null,
                                          child: Container(
                                            width: 120,
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey[300]!),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 32,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        );
                                      }

                                      return Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                _selectedImages[index],
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _removeImage(index),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (index == 0)
                                              Positioned(
                                                bottom: 4,
                                                left: 4,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    'Principal',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_selectedImages.length}/10 fotos adicionadas',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Basic info section
                    _buildSection(
                      title: 'Informações Básicas',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration:
                                _buildInputDecoration('Título do anúncio'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Campo obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                _buildInputDecoration('Descrição (opcional)'),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Category dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: _buildInputDecoration('Categoria'),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecione uma categoria';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Bike type dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedBikeType,
                            decoration:
                                _buildInputDecoration('Tipo de bicicleta'),
                            items: _bikeTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_getBikeTypeLabel(type)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedBikeType = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pricing section
                    _buildSection(
                      title: 'Preços',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _pricePerHourController,
                                  decoration: _buildInputDecoration(
                                      'Preço por hora (R\$)'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Campo obrigatório';
                                    }
                                    if (double.tryParse(value!) == null) {
                                      return 'Valor inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _pricePerDayController,
                                  decoration: _buildInputDecoration(
                                      'Preço por dia (R\$) - opcional'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isNotEmpty == true &&
                                        double.tryParse(value!) == null) {
                                      return 'Valor inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location section
                    _buildSection(
                      title: 'Localização',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _addressController,
                            decoration: _buildInputDecoration('Endereço'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Campo obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: _buildInputDecoration('Cidade'),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Campo obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _countryController,
                                  decoration: _buildInputDecoration('País'),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Campo obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Features section
                    _buildSection(
                      title: 'Recursos Inclusos',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecione os recursos que acompanham sua bicicleta:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableFeatures.map((feature) {
                              final isSelected = _features.contains(feature);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _features.remove(feature);
                                    } else {
                                      _features.add(feature);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    feature,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rules section
                    _buildSection(
                      title: 'Regras e Observações',
                      child: TextFormField(
                        controller: _rulesController,
                        decoration: _buildInputDecoration(
                            'Regras de uso, cuidados especiais, etc. (opcional)'),
                        maxLines: 4,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitListing,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)
              : Text(
                  'Publicar Anúncio',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.grey[600],
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String _getBikeTypeLabel(String bikeType) {
    switch (bikeType) {
      case 'city':
        return 'Urbana';
      case 'mountain':
        return 'Mountain Bike';
      case 'electric':
        return 'Elétrica';
      case 'hybrid':
        return 'Híbrida';
      case 'road':
        return 'Speed';
      default:
        return 'Urbana';
    }
  }
}
