import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/qr_checkin_token.dart';
import '../../../shared/widgets/fitsync_button.dart';
import '../providers/membership_provider.dart';

class TurnstileSimulatorModal extends ConsumerStatefulWidget {
  final String qrPayload;

  const TurnstileSimulatorModal({
    super.key,
    required this.qrPayload,
  });

  @override
  ConsumerState<TurnstileSimulatorModal> createState() =>
      _TurnstileSimulatorModalState();
}

class _TurnstileSimulatorModalState
    extends ConsumerState<TurnstileSimulatorModal> {
  String _selectedGate = 'Main Gate - Turnstile 01';
  bool _isProcessing = false;
  QrValidationResult? _validationResult;
  bool _hasCheckedIn = false;

  final List<String> _gates = [
    'Main Gate - Turnstile 01',
    'Main Gate - Turnstile 02',
    'VIP & Cardio Gate B',
    'Locker Room Gate North',
  ];

  Future<void> _simulateScan() async {
    setState(() {
      _isProcessing = true;
      _validationResult = null;
    });

    // Simulate laser scan delay
    await Future.delayed(const Duration(milliseconds: 700));

    final result = QrCheckinToken.validate(widget.qrPayload);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _validationResult = result;
      });

      if (result.isValid && !_hasCheckedIn) {
        _hasCheckedIn = true;
        await ref
            .read(membershipActionControllerProvider)
            .recordTurnstileCheckIn(
              location: _selectedGate,
              notes: 'Verifikasi Turnstile Otomatis',
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
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
                      'Simulasi Scanner Turnstile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Uji pemindaian kode QR Anda di pintu masuk gym',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gate Dropdown Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGate = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Scan Result Card / Status
          if (_validationResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _validationResult!.isValid
                    ? AppColors.primaryContainer
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _validationResult!.isValid
                      ? AppColors.primary
                      : AppColors.error,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _validationResult!.isValid
                          ? AppColors.primary
                          : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _validationResult!.isValid
                          ? Icons.check_rounded
                          : Icons.block_rounded,
                      color: AppColors.background,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _validationResult!.isValid
                              ? 'AKSES DIBERIKAN!'
                              : 'AKSES DITOLAK',
                          style: TextStyle(
                            color: _validationResult!.isValid
                                ? AppColors.primary
                                : AppColors.error,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _validationResult!.message,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                        if (_validationResult!.isValid) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Gate: $_selectedGate • Turnstile Terbuka',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Button
          FitSyncButton(
            text: _isProcessing
                ? 'Memindai Laser...'
                : (_validationResult == null
                    ? 'Pindai Kode QR Sekarang'
                    : 'Uji Pindai Lagi'),
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.background,
              size: 20,
            ),
            isLoading: _isProcessing,
            onPressed: _simulateScan,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Simulasi verifikasi HMAC-SHA256 & masa berlaku 60 detik.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
