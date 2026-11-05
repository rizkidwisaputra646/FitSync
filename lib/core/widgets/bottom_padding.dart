import 'package:flutter/widgets.dart';

/// Widget pengatur jarak aman bawah (breathing room) yang beradaptasi dinamis
/// dengan tinggi bilah navigasi sistem (Android gesture pill / iOS home bar).
class BottomPadding extends StatelessWidget {
  const BottomPadding({
    super.key,
    this.minimum = 16.0,
  });

  final double minimum;

  static double of(
    BuildContext context, {
    double minimum = 16.0,
  }) {
    final double viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    return viewPadding > minimum ? viewPadding : minimum;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: of(context, minimum: minimum));
  }
}

