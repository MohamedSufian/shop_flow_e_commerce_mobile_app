import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';

/// Live preview of the (demo) card being entered.
class PaymentCardPreview extends StatelessWidget {
  const PaymentCardPreview({super.key, required this.number, required this.holder, required this.expiry});

  final String number;
  final String holder;
  final String expiry;

  String get _brand {
    final n = number.replaceAll(' ', '');
    if (n.startsWith('4')) return 'VISA';
    if (RegExp(r'^5[1-5]').hasMatch(n)) return 'Mastercard';
    return 'CARD';
  }

  String get _masked {
    final digits = number.replaceAll(' ', '').padRight(16, '•');
    return List.generate(4, (i) => digits.substring(i * 4, i * 4 + 4)).join('  ');
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF4338CA), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.contactless_rounded, color: Colors.white70),
                    const Spacer(),
                    Text(
                      _brand,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  child: Text(
                    _masked,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _Label(title: 'CARD HOLDER', value: holder.isEmpty ? context.tr('YOUR NAME') : holder.toUpperCase()),
                    ),
                    _Label(title: 'EXPIRES', value: expiry.isEmpty ? 'MM/YY' : expiry),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(title), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}
