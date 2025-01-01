import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimationState {
  final bool isPlaying;
  final double progress;

  AnimationState({
    this.isPlaying = false,
    this.progress = 0.0,
  });

  AnimationState copyWith({
    bool? isPlaying,
    double? progress,
  }) {
    return AnimationState(
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
    );
  }
}

class AnimationNotifier extends StateNotifier<AnimationState> {
  AnimationNotifier() : super(AnimationState());

  void toggleAnimation() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }
}

final animationProvider = StateNotifierProvider<AnimationNotifier, AnimationState>((ref) {
  return AnimationNotifier();
});
