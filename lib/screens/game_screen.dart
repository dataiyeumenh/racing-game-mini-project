import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/cow_data.dart';
import '../services/audio_service.dart';
import '../widgets/cow_sprite.dart';
import '../widgets/betting_panel.dart';
import '../widgets/result_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _random = Random();
  final _audio = AudioService();

  int _balance = kInitialBalance;
  int _winnerIndex = -1;
  GamePhase _phase = GamePhase.betting;

  List<int> _betAmounts = [];
  Map<int, int> _confirmedBets = {};

  Timer? _raceTimer;
  Timer? _animTimer;

  late List<CowData> _cows;

  @override
  void initState() {
    super.initState();
    _cows = CowData.defaultCows();
    _betAmounts = List.filled(_cows.length, 0);
    _audio.playBgm();
  }

  @override
  void dispose() {
    _raceTimer?.cancel();
    _animTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }

  int get _totalEntered => _betAmounts.fold(0, (a, b) => a + b);

  void _increaseBet(int i) {
    if (_totalEntered + 10 > _balance) return;
    setState(() => _betAmounts[i] += 10);
    _audio.playCoin();
  }

  void _decreaseBet(int i) {
    if (_betAmounts[i] < 10) return;
    setState(() => _betAmounts[i] -= 10);
    _audio.playCoin();
  }

  void _startRace() {
    FocusScope.of(context).unfocus();

    // Collect per-cow bets
    final Map<int, int> bets = {};
    for (int i = 0; i < _cows.length; i++) {
      final amount = _betAmounts[i];
      if (amount > 0) bets[i] = amount;
    }

    if (bets.isEmpty) {
      _showSnack('Hãy đặt cược cho ít nhất 1 con bò!');
      return;
    }

    final total = bets.values.fold(0, (a, b) => a + b);
    if (total > _balance) {
      _showSnack('Tổng cược ($total xu) vượt quá số dư!');
      return;
    }

    setState(() {
      _confirmedBets = Map.from(bets);
      _balance -= total;
      _phase = GamePhase.racing;
      _winnerIndex = -1;
    });

    _audio.playSfx('start.mp3');

    for (final cow in _cows) {
      cow.reset();
      cow.state = CowState.running;
      cow.speed = 0.008 + _random.nextDouble() * 0.010;
    }

    _animTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        for (final cow in _cows) {
          cow.animFrame++;
        }
      });
    });

    _raceTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _cows.length; i++) {
          final cow = _cows[i];
          if (cow.state == CowState.running) {
            final jitter = (_random.nextDouble() - 0.5) * 0.004;
            cow.position += cow.speed + jitter;
            if (cow.position >= 1.0) {
              cow.position = 1.0;
              if (_winnerIndex < 0) _winnerIndex = i;
            }
          }
        }
        if (_winnerIndex >= 0) _finishRace();
      });
    });
  }

  void _finishRace() {
    _raceTimer?.cancel();

    for (int i = 0; i < _cows.length; i++) {
      if (i == _winnerIndex) {
        _cows[i].state = CowState.jumping;
        _cows[i].animFrame = 0;
      } else {
        _cows[i].state = CowState.idle;
      }
    }

    // Payout: return winning cow bet × multiplier
    final winBet = _confirmedBets[_winnerIndex] ?? 0;
    if (winBet > 0) {
      _balance += (winBet * kMultiplier).round();
    }

    _audio.stopBgm();
    _audio.playSfx(winBet > 0 ? 'win.mp3' : 'lose.mp3', loop: true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _phase = GamePhase.finished);
    });
  }

  void _resetGame() {
    _animTimer?.cancel();
    _raceTimer?.cancel();
    _audio.stopSfx();
    _audio.stopCoin();
    _betAmounts = List.filled(_cows.length, 0);
    _audio.playBgm();
    setState(() {
      _confirmedBets = {};
      _winnerIndex = -1;
      _phase = GamePhase.betting;
      for (final cow in _cows) {
        cow.reset();
      }
    });
  }

  void _freeCoins() {
    setState(() => _balance = kInitialBalance);
    _resetGame();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main game UI always present underneath
            Column(
              children: [
                _buildHeader(),
                _buildTrack(),
                const SizedBox(height: 8),
                BettingPanel(
                  phase: _phase,
                  cows: _cows,
                  betAmounts: _betAmounts,
                  confirmedBets: _confirmedBets,
                  balance: _balance,
                  totalEntered: _totalEntered,
                  onStartRace: _startRace,
                  onIncrease: _increaseBet,
                  onDecrease: _decreaseBet,
                ),
              ],
            ),
            // Full-screen result overlay
            if (_phase == GamePhase.finished)
              Positioned.fill(
                child: ResultPanel(
                  cows: _cows,
                  winnerIndex: _winnerIndex,
                  confirmedBets: _confirmedBets,
                  balance: _balance,
                  onPlayAgain: _balance > 0 ? _resetGame : null,
                  onGetFreeCoins: _balance <= 0 ? _freeCoins : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF0D2B0D),
      child: Row(
        children: [
          const Text(
            'COW RACING',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Image.asset(
            'assets/images/coin.png',
            width: 24,
            height: 24,
            errorBuilder: (_, _, _) => const Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$_balance',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrack() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final trackHeight = constraints.maxHeight;

          // track.png has decorative top (~18%) and bottom (~12%)
          const trackTopFraction = 0.18;
          const trackBottomFraction = 0.12;
          final raceTop = trackHeight * trackTopFraction;
          final raceHeight =
              trackHeight * (1 - trackTopFraction - trackBottomFraction);
          final laneHeight = raceHeight / 3;
          // Drawable width: total - cow size - small margin
          final drawableWidth = trackWidth - kCowSize - 16;

          return Stack(
            children: [
              // Background track
              Positioned.fill(
                child: Image.asset(
                  'assets/images/track.png',
                  fit: BoxFit.fill,
                  errorBuilder: (_, _, _) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D5A27), Color(0xFF3D7A35)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),

              // Finish line
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/images/finish_line.png',
                  width: 40,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (_, _, _) =>
                      Container(width: 6, color: Colors.white),
                ),
              ),

              // Lane dividers
              ...List.generate(2, (i) {
                final y = raceTop + laneHeight * (i + 1);
                return Positioned(
                  left: 0,
                  right: 0,
                  top: y,
                  child: Container(
                    height: 1.5,
                    color: Colors.white.withAlpha(60),
                  ),
                );
              }),

              ...List.generate(_cows.length, (i) {
                final cow = _cows[i];
                final topOffset =
                    raceTop + laneHeight * i + (laneHeight - kCowSize) / 2;
                final leftOffset = 8.0 + cow.position * drawableWidth;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 60),
                  left: leftOffset,
                  top: topOffset,
                  child: CowSprite(
                    cow: cow,
                    highlighted:
                        _phase == GamePhase.betting && _betAmounts[i] > 0,
                  ),
                );
              }),

              // Destination banner
              if (_winnerIndex >= 0)
                Positioned(
                  right: 50,
                  top: 8,
                  child: Image.asset(
                    'assets/images/destination_banner.png',
                    height: 50,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
