import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/animation_provider.dart';
import 'player_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Pure Sound',
      subtitle: 'Your music, beautifully simple',
      lottieAsset: 'assets/animations/headphones.json',
    ),
    OnboardingItem(
      title: 'Solo or Social',
      subtitle: 'Switch modes to match your mood',
      lottieAsset: 'assets/animations/mode-switch.json',
    ),
    OnboardingItem(
      title: 'Mark Favorites',
      subtitle: 'Save tracks you love',
      lottieAsset: 'assets/animations/heart.json',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _items.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildLottieAnimation(String asset) {
    final animationState = ref.watch(animationProvider);
    
    return Lottie.asset(
      asset,
      repeat: true,
      animate: animationState.isPlaying,
      onLoaded: (composition) {
        ref.read(animationProvider.notifier).updateProgress(1.0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _OnboardingPage(
                  title: _items[index].title,
                  subtitle: _items[index].subtitle,
                  animation: _buildLottieAnimation(_items[index].lottieAsset),
                );
              },
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _items.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    expansionFactor: 4,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PlayerScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget animation;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: animation,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String lottieAsset;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
  });
}
