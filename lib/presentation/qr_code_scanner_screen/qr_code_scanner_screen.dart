import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/error_dialog_widget.dart';
import './widgets/manual_entry_dialog_widget.dart';
import './widgets/scanner_header_widget.dart';
import './widgets/scanner_overlay_widget.dart';
import './widgets/unlock_confirmation_dialog_widget.dart';

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashlightOn = false;
  bool _isFlashlightAvailable = false;
  bool _isScanning = false;
  bool _hasPermission = false;
  String? _lastScannedCode;
  Timer? _scanningTimer;

  // Mock bike data for demonstration
  final List<Map<String, dynamic>> _mockBikes = [
    {
      "id": "BK001",
      "model": "Bike Urbana Classic",
      "location": "Praça da Sé, Centro",
      "image":
          "https://images.pexels.com/photos/100582/pexels-photo-100582.jpeg",
      "qrCode": "BIKE001QR",
      "isAvailable": true,
      "owner": "João Silva",
      "pricePerHour": "R\$ 8,00",
    },
    {
      "id": "BK002",
      "model": "Mountain Bike Pro",
      "location": "Parque Ibirapuera",
      "image":
          "https://images.pexels.com/photos/544966/pexels-photo-544966.jpeg",
      "qrCode": "BIKE002QR",
      "isAvailable": true,
      "owner": "Maria Santos",
      "pricePerHour": "R\$ 12,00",
    },
    {
      "id": "BK003",
      "model": "Bike Elétrica Urban",
      "location": "Vila Madalena",
      "image":
          "https://images.pexels.com/photos/1149601/pexels-photo-1149601.jpeg",
      "qrCode": "BIKE003QR",
      "isAvailable": false,
      "owner": "Pedro Costa",
      "pricePerHour": "R\$ 15,00",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanningTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        setState(() {
          _hasPermission = false;
        });
        _showPermissionDialog();
        return;
      }

      setState(() {
        _hasPermission = true;
      });

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorDialog(
          'Câmera Indisponível',
          'Nenhuma câmera foi encontrada neste dispositivo.',
        );
        return;
      }

      // Initialize camera controller
      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Check flashlight availability
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashlightAvailable = true;
      } catch (e) {
        _isFlashlightAvailable = false;
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startScanning();
      }
    } catch (e) {
      _showErrorDialog(
        'Erro na Câmera',
        'Não foi possível inicializar a câmera. Verifique as permissões e tente novamente.',
        actionText: 'Tentar Novamente',
        onAction: _initializeCamera,
      );
    }
  }

  void _startScanning() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    // Simulate QR code scanning with timer
    _scanningTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }

      // Simulate random QR code detection
      if (Random().nextBool()) {
        final randomBike = _mockBikes[Random().nextInt(_mockBikes.length)];
        _onQrCodeDetected(randomBike["qrCode"] as String);
        timer.cancel();
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanningTimer?.cancel();
  }

  void _onQrCodeDetected(String code) {
    if (_lastScannedCode == code) return;

    _lastScannedCode = code;
    _stopScanning();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Process QR code
    _processQrCode(code);
  }

  void _processQrCode(String code) {
    // Find bike by QR code
    final bike = _mockBikes.firstWhere(
      (bike) => (bike["qrCode"] as String).toLowerCase() == code.toLowerCase(),
      orElse: () => {},
    );

    if (bike.isEmpty) {
      _showErrorDialog(
        'Código Inválido',
        'O código QR escaneado não corresponde a nenhuma bicicleta cadastrada.',
        actionText: 'Escanear Novamente',
        onAction: () {
          Navigator.of(context).pop();
          _startScanning();
        },
      );
      return;
    }

    if (!(bike["isAvailable"] as bool)) {
      _showErrorDialog(
        'Bicicleta Indisponível',
        'Esta bicicleta já está sendo utilizada por outro usuário.',
        actionText: 'Buscar Outra',
        onAction: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
      return;
    }

    // Show unlock confirmation
    _showUnlockConfirmation(bike);
  }

  void _showUnlockConfirmation(Map<String, dynamic> bikeData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnlockConfirmationDialogWidget(
        bikeData: bikeData,
        onStartRide: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Close scanner
          Fluttertoast.showToast(
            msg: "Pedalada iniciada! Divirta-se!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppTheme.getSuccessColor(true),
            textColor: Colors.white,
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
          _startScanning();
        },
      ),
    );
  }

  void _showManualEntryDialog() {
    _stopScanning();
    showDialog(
      context: context,
      builder: (context) => ManualEntryDialogWidget(
        onCodeSubmitted: (code) {
          Navigator.of(context).pop();
          _processQrCode(code);
        },
      ),
    ).then((_) {
      // Resume scanning if dialog was dismissed
      if (mounted) {
        _startScanning();
      }
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialogWidget(
        title: 'Permissão Necessária',
        message:
            'Para escanear códigos QR e desbloquear bicicletas, precisamos acessar sua câmera.',
        actionText: 'Permitir',
        onAction: () {
          Navigator.of(context).pop();
          _initializeCamera();
        },
        onDismiss: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorDialog(
    String title,
    String message, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialogWidget(
        title: title,
        message: message,
        actionText: actionText,
        onAction: onAction,
        onDismiss: () {
          Navigator.of(context).pop();
          if (actionText == null) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _toggleFlashlight() async {
    if (!_isFlashlightAvailable || _cameraController == null) return;

    try {
      if (_isFlashlightOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      setState(() {
        _isFlashlightOn = !_isFlashlightOn;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Não foi possível controlar a lanterna",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or permission request
          if (!_hasPermission)
            _buildPermissionView()
          else if (_isCameraInitialized && _cameraController != null)
            _buildCameraView()
          else
            _buildLoadingView(),

          // Scanner overlay
          if (_hasPermission && _isCameraInitialized)
            ScannerOverlayWidget(
              isScanning: _isScanning,
              onManualEntry: _showManualEntryDialog,
            ),

          // Header with controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScannerHeaderWidget(
              onBackPressed: () => Navigator.of(context).pop(),
              onFlashlightToggle: _toggleFlashlight,
              isFlashlightOn: _isFlashlightOn,
              isFlashlightAvailable: _isFlashlightAvailable,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildPermissionView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white.withValues(alpha: 0.7),
              size: 15.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'Permissão de Câmera Necessária',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Para escanear códigos QR e desbloquear bicicletas, precisamos acessar sua câmera.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Permitir Acesso',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.primaryColor,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Inicializando câmera...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
