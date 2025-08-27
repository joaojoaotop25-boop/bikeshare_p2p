import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoUploadWidget extends StatefulWidget {
  final Function(List<XFile>) onPhotosChanged;
  final List<XFile> initialPhotos;

  const PhotoUploadWidget({
    Key? key,
    required this.onPhotosChanged,
    this.initialPhotos = const [],
  }) : super(key: key);

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  List<XFile> _photos = [];
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.initialPhotos);
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _photos.add(photo);
        _showCamera = false;
      });
      widget.onPhotosChanged(_photos);
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _photos.addAll(images);
        });
        widget.onPhotosChanged(_photos);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
    widget.onPhotosChanged(_photos);
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final XFile item = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, item);
    });
    widget.onPhotosChanged(_photos);
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
                iconName: 'photo_camera',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Fotos da Bicicleta',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${_photos.length}/10',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_showCamera && _isCameraInitialized && _cameraController != null)
            Container(
              height: 40.h,
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
                    CameraPreview(_cameraController!),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showCamera = false;
                              });
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _capturePhoto,
                            icon: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'camera_alt',
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _pickFromGallery,
                            icon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'photo_library',
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                if (_photos.isNotEmpty)
                  Container(
                    height: 25.h,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      onReorder: _reorderPhotos,
                      itemBuilder: (context, index) {
                        return Container(
                          key: ValueKey(_photos[index].path),
                          width: 35.w,
                          margin: EdgeInsets.only(right: 2.w),
                          child: Stack(
                            children: [
                              Container(
                                width: 35.w,
                                height: 25.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: index == 0
                                        ? AppTheme.lightTheme.primaryColor
                                        : AppTheme
                                            .lightTheme.colorScheme.outline,
                                    width: index == 0 ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(
                                          _photos[index].path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          _photos[index].path,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: CustomIconWidget(
                                                iconName: 'image',
                                                color: Colors.grey[600]!,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                              if (index == 0)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Principal',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'close',
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'drag_handle',
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _photos.length < 10
                            ? () {
                                setState(() {
                                  _showCamera = true;
                                });
                              }
                            : null,
                        icon: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: _photos.length < 10
                              ? AppTheme.lightTheme.primaryColor
                              : Colors.grey,
                          size: 20,
                        ),
                        label: Text('Câmera'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _photos.length < 10 ? _pickFromGallery : null,
                        icon: CustomIconWidget(
                          iconName: 'photo_library',
                          color: _photos.length < 10
                              ? AppTheme.lightTheme.primaryColor
                              : Colors.grey,
                          size: 20,
                        ),
                        label: Text('Galeria'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (_photos.isEmpty)
            Container(
              height: 20.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'add_photo_alternate',
                    color: Colors.grey[400]!,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Adicione fotos da sua bicicleta',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'A primeira foto será a principal',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
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
