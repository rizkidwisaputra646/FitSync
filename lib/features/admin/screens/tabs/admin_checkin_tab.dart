import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fitsync_button.dart';
import '../../../../shared/widgets/fitsync_card.dart';
import '../../providers/admin_provider.dart';

class AdminCheckinTab extends ConsumerStatefulWidget {
  const AdminCheckinTab({super.key});

  @override
  ConsumerState<AdminCheckinTab> createState() => _AdminCheckinTabState();
}

class _AdminCheckinTabState extends ConsumerState<AdminCheckinTab> {
  String _selectedGate = 'Main Gate - Turnstile 01';

  final List<String> _gates = [
    'Main Gate - Turnstile 01',
    'Main Gate - Turnstile 02',
    'Cardio & Functional Gate B',
    'VIP Lounge Gate North',
  ];

  void _openCameraScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CameraScannerView(
          gateName: _selectedGate,
          onScanCompleted: (payload) => _handleProcessPayload(context, payload),
        ),
      ),
    );
  }

  void _openManualInputModal(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Input Manual Kode QR',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Gunakan jika kamera mengalami kendala atau untuk pengujian cepat payload FITSYNC:...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Tempel payload QR di sini...',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.surface,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            FitSyncButton(
              text: 'Verifikasi Token Sekarang',
              icon: const Icon(Icons.check_rounded,
                  color: AppColors.background, size: 18),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                _handleProcessPayload(context, text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleProcessPayload(BuildContext context, String payload) async {
    // Show validation progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final result = await ref
        .read(adminActionControllerProvider)
        .processQrScan(qrPayload: payload, gateName: _selectedGate);

    if (!mounted || !context.mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (!context.mounted) return;
    // Show Result Alert
    showDialog(
      context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.isValid
                      ? AppColors.primary
                      : AppColors.error,
                ),
                child: Icon(
                  result.isValid
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: AppColors.background,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                result.isValid ? 'AKSES DIBERIKAN!' : 'AKSES DITOLAK',
                style: TextStyle(
                  color: result.isValid ? AppColors.primary : AppColors.error,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gate: $_selectedGate',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceHighlight,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final checkinsAsync = ref.watch(adminCheckinsListProvider);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gate Selector Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOKASI PINTU TURNSTILE AKTIF',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGate,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary),
                    items: _gates.map((g) {
                      return DropdownMenuItem<String>(
                        value: g,
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGate = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Scan QR CTA Buttons
          FitSyncButton(
            text: 'Buka Pemindai Kamera QR',
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: AppColors.background, size: 20),
            onPressed: () => _openCameraScanner(context),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => _openManualInputModal(context),
              icon: const Icon(Icons.keyboard_outlined,
                  size: 16, color: AppColors.primary),
              label: const Text(
                'Uji Coba dengan Input Manual Token QR',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Today's Checkins Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Kunjungan Masuk Hari Ini',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              checkinsAsync.maybeWhen(
                data: (list) => Text(
                  '${list.length} Check-In',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          checkinsAsync.when(
            data: (checkins) {
              if (checkins.isEmpty) {
                return FitSyncCard(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'Belum ada member yang melakukan check-in hari ini.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: checkins.take(10).map((record) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FitSyncCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.sensor_door_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.location,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormat.format(record.timestamp),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                                if (record.notes.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    record.notes,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Text('Gagal memuat log check-in: $err'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraScannerView extends StatefulWidget {
  final String gateName;
  final Function(String payload) onScanCompleted;

  const _CameraScannerView({
    required this.gateName,
    required this.onScanCompleted,
  });

  @override
  State<_CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<_CameraScannerView> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _hasDetected = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Pemindai Turnstile (${widget.gateName})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: AppColors.primary),
            onPressed: () => _cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded,
                color: AppColors.textPrimary),
            onPressed: () => _cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (_hasDetected) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final raw = barcode.rawValue;
                if (raw != null && raw.isNotEmpty) {
                  _hasDetected = true;
                  Navigator.pop(context);
                  widget.onScanCompleted(raw);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2.5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              'Arahkan kotak ke Kode QR Dinamis di aplikasi member',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
