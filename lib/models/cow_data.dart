import 'package:flutter/material.dart';

enum CowState { idle, running, jumping }

enum GamePhase { betting, racing, finished }

class CowData {
  final String id;
  final String label;
  final Color color;

  final String idleFrame;
  final String toBetFrame;
  final List<String> runFrames;
  final List<String> jumpFrames;

  CowState state = CowState.idle;
  double position = 0.0;
  double speed = 0.0;
  int animFrame = 0;

  CowData({
    required this.id,
    required this.label,
    required this.color,
    required this.idleFrame,
    required this.toBetFrame,
    required this.runFrames,
    required this.jumpFrames,
  });

  String get currentAsset {
    switch (state) {
      case CowState.idle:
        return idleFrame;
      case CowState.running:
        return runFrames[animFrame % runFrames.length];
      case CowState.jumping:
        return jumpFrames[animFrame % jumpFrames.length];
    }
  }

  void reset() {
    state = CowState.idle;
    position = 0.0;
    speed = 0.0;
    animFrame = 0;
  }

  /// Returns the pre-built list of all three cows.
  static List<CowData> defaultCows() => [
    CowData(
      id: 'brown',
      label: 'Bò Nâu',
      color: const Color(0xFF8B4513),
      idleFrame: 'assets/images/cow_brown_idle.png',
      toBetFrame: 'assets/images/cow_brown_to_bet.png',
      runFrames: List.generate(
        6,
        (i) => 'assets/images/cow_brown_run_frame_${i + 1}.png',
      ),
      jumpFrames: List.generate(
        2,
        (i) => 'assets/images/cow_brown_jump_frame_${i + 1}.png',
      ),
    ),
    CowData(
      id: 'milk',
      label: 'Bò Trắng',
      color: const Color(0xFFEEEEEE),
      idleFrame: 'assets/images/cow_milk_idle.png',
      toBetFrame: 'assets/images/cow_milk_to_bet.png',
      runFrames: List.generate(
        6,
        (i) => 'assets/images/cow_milk_run_frame_${i + 1}.png',
      ),
      jumpFrames: List.generate(
        2,
        (i) => 'assets/images/cow_milk_jump_frame_${i + 1}.png',
      ),
    ),
    CowData(
      id: 'red',
      label: 'Bò Đỏ',
      color: const Color(0xFFCC2200),
      idleFrame: 'assets/images/cow_red_idle.png',
      toBetFrame: 'assets/images/cow_red_to_bet.png',
      runFrames: List.generate(
        6,
        (i) => 'assets/images/cow_red_run_frame_${i + 1}.png',
      ),
      jumpFrames: List.generate(
        2,
        (i) => 'assets/images/cow_red_jump_frame_${i + 1}.png',
      ),
    ),
  ];
}
