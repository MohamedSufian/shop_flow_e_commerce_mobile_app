import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../auth/auth_gate.dart';
import '../../core/l10n/l10n.dart';

class _OnboardData {
  final IconData icon;
  final IconData badge;
  final String title;
  final String subtitle;
  final List<Color> colors;

  const _OnboardData(this.icon, this.badge, this.title, this.subtitle, this.colors);
}

const _pages = [
  _OnboardData(
    Icons.storefront_rounded,
    Icons.auto_awesome_rounded,
    'Discover thousands\nof products',
    'Explore curated collections across fashion, beauty, tech and home — all in one place.',
    [Color(0xFF7B5CFF), Color(0xFF5B4BF5)],
  ),
  _OnboardData(
    Icons.local_offer_rounded,
    Icons.percent_rounded,
    'Exclusive deals\nevery day',
    'Save more with daily discounts, flash sales and offers picked just for you.',
    [Color(0xFFFF9A6C), Color(0xFFFF6B6B)],
  ),
  _OnboardData(
    Icons.local_shipping_rounded,
    Icons.verified_rounded,
    'Fast & secure\ncheckout',
    'Pay safely, track your order in real time and get it delivered to your door.',
    [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await context.read<LocalStorage>().setOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const AuthGate(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedOpacity(
                opacity: _isLast ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: TextButton(
                  onPressed: _isLast ? null : _finish,
                  child: Tr('Skip', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardPage(data: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: active ? AppColors.primaryGradient : null,
                          color: active ? null : theme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: _isLast ? 'Get Started' : 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.data});

  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = data.colors.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Layered illustration
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.07)),
                ),
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.12)),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    gradient: LinearGradient(
                      colors: data.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 16)),
                    ],
                  ),
                  child: Icon(data.icon, size: 68, color: Colors.white),
                ),
                Positioned(
                  top: 44,
                  right: 40,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(data.badge, color: c, size: 26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            context.tr(data.title),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(height: 1.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr(data.subtitle),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
