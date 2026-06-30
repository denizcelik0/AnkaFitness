import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/admin_viewmodel.dart';

/// Admin QR kod tarama ekranı.
/// Kamera ile üye QR kodlarını tarayarak giriş kaydı oluşturur.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  String? _lastResult;
  bool? _lastSuccess;
  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnimation;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resultFadeAnimation = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('QR Tarama'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          // Flash toggle
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    state.torchState == TorchState.on
                        ? Icons.flash_on
                        : Icons.flash_off,
                    size: 20,
                  ),
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // ── Kamera Görüntüsü ──
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // ── Tarama Çerçevesi Overlay ──
          _buildScanOverlay(),

          // ── Alt Sonuç Paneli ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildResultPanel(),
          ),
        ],
      ),
    );
  }

  /// Tarama çerçevesi overlay'i.
  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 40;

        return Stack(
          children: [
            // Koyu overlay
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // Renk önemli değil, cutout için
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Köşe dekorları
            Positioned(
              left: left - 2,
              top: top - 2,
              child: _buildCorner(true, true),
            ),
            Positioned(
              right: left - 2,
              top: top - 2,
              child: _buildCorner(false, true),
            ),
            Positioned(
              left: left - 2,
              bottom: constraints.maxHeight - top - scanAreaSize - 2,
              child: _buildCorner(true, false),
            ),
            Positioned(
              right: left - 2,
              bottom: constraints.maxHeight - top - scanAreaSize - 2,
              child: _buildCorner(false, false),
            ),
            // Talimat metni
            Positioned(
              left: 0,
              right: 0,
              top: top + scanAreaSize + 24,
              child: Text(
                'Üyenin QR kodunu çerçeveye yerleştirin',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Köşe dekor widget'ı.
  Widget _buildCorner(bool isLeft, bool isTop) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _CornerPainter(
          isLeft: isLeft,
          isTop: isTop,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Alt sonuç paneli.
  Widget _buildResultPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        MediaQuery.of(context).padding.bottom + AppConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withValues(alpha: 0.95),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_lastResult != null)
            FadeTransition(
              opacity: _resultFadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: _lastSuccess == true
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: _lastSuccess == true
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastSuccess == true
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: _lastSuccess == true
                          ? AppColors.success
                          : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lastResult!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _lastSuccess == true
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ],
      ),
    );
  }

  /// QR kod algılandığında çalışır.
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final qrData = barcodes.first.rawValue!;
    setState(() => _isProcessing = true);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    final adminVM = context.read<AdminViewModel>();
    final result = await adminVM.verifyAndRecordEntry(qrData);

    if (mounted) {
      setState(() {
        _lastResult = result.message;
        _lastSuccess = result.success;
        _isProcessing = false;
      });

      _resultAnimController.forward(from: 0);

      // Başarılı: yeşil feedback, 2 saniye sonra sıfırla
      if (result.success) {
        HapticFeedback.heavyImpact();
      }

      // 3 saniye sonra tekrar taramaya hazır ol
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _resultAnimController.reverse();
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          setState(() {
            _lastResult = null;
            _lastSuccess = null;
          });
        }
      }
    }
  }
}

/// Tarama çerçevesi köşe çizici.
class _CornerPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;
  final Color color;

  _CornerPainter({
    required this.isLeft,
    required this.isTop,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isLeft && isTop) {
      path.moveTo(0, size.height * 0.6);
      path.lineTo(0, 8);
      path.quadraticBezierTo(0, 0, 8, 0);
      path.lineTo(size.width * 0.6, 0);
    } else if (!isLeft && isTop) {
      path.moveTo(size.width * 0.4, 0);
      path.lineTo(size.width - 8, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 8);
      path.lineTo(size.width, size.height * 0.6);
    } else if (isLeft && !isTop) {
      path.moveTo(0, size.height * 0.4);
      path.lineTo(0, size.height - 8);
      path.quadraticBezierTo(0, size.height, 8, size.height);
      path.lineTo(size.width * 0.6, size.height);
    } else {
      path.moveTo(size.width * 0.4, size.height);
      path.lineTo(size.width - 8, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - 8);
      path.lineTo(size.width, size.height * 0.4);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
