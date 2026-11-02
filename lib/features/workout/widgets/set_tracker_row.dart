import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/workout_session.dart';

class SetTrackerRow extends StatefulWidget {
  final LoggedSet set;
  final VoidCallback onToggleComplete;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  const SetTrackerRow({
    super.key,
    required this.set,
    required this.onToggleComplete,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  @override
  State<SetTrackerRow> createState() => _SetTrackerRowState();
}

class _SetTrackerRowState extends State<SetTrackerRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.actualWeightKg > 0
          ? widget.set.actualWeightKg.toStringAsFixed(
              widget.set.actualWeightKg.truncateToDouble() ==
                      widget.set.actualWeightKg
                  ? 0
                  : 1)
          : '',
    );
    _repsController = TextEditingController(
      text: widget.set.actualReps > 0 ? widget.set.actualReps.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant SetTrackerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set.actualWeightKg != widget.set.actualWeightKg) {
      final text = widget.set.actualWeightKg > 0
          ? widget.set.actualWeightKg.toStringAsFixed(
              widget.set.actualWeightKg.truncateToDouble() ==
                      widget.set.actualWeightKg
                  ? 0
                  : 1)
          : '';
      if (_weightController.text != text) {
        _weightController.text = text;
      }
    }
    if (oldWidget.set.actualReps != widget.set.actualReps) {
      final text =
          widget.set.actualReps > 0 ? widget.set.actualReps.toString() : '';
      if (_repsController.text != text) {
        _repsController.text = text;
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.set.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.primaryContainer.withValues(alpha: 0.25)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? AppColors.primary : AppColors.border,
          width: isDone ? 1.4 : 0.8,
        ),
      ),
      child: Row(
        children: [
          // Set Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : AppColors.surfaceHighlight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.set.setNumber}',
                style: TextStyle(
                  color: isDone ? AppColors.textOnPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Weight Input (kg)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDone ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0.0;
                      widget.onWeightChanged(parsed);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'kg',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Reps Input
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDone ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: '${widget.set.targetReps}',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      widget.onRepsChanged(parsed);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'reps',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Toggle Complete Button
          GestureDetector(
            onTap: widget.onToggleComplete,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.check_outlined,
                color: isDone ? AppColors.textOnPrimary : AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
