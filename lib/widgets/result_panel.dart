import 'package:flutter/material.dart';
import '../models/cow_data.dart';
import '../core/constants.dart';

class ResultPanel extends StatelessWidget {
  final List<CowData> cows;
  final int winnerIndex;
  final Map<int, int> confirmedBets;
  final int balance;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onGetFreeCoins;

  const ResultPanel({
    super.key,
    required this.cows,
    required this.winnerIndex,
    required this.confirmedBets,
    required this.balance,
    this.onPlayAgain,
    this.onGetFreeCoins,
  });

  int get _winBet => confirmedBets[winnerIndex] ?? 0;
  bool get _didWin => _winBet > 0;
  int get _totalBet => confirmedBets.values.fold(0, (a, b) => a + b);
  int get _payout => _didWin ? (_winBet * kMultiplier).round() : 0;
  int get _netResult => _payout - _totalBet;

  @override
  Widget build(BuildContext context) {
    final winnerCow = winnerIndex >= 0 ? cows[winnerIndex] : null;

    return Container(
      color: const Color(0xE6071A07), // ~90% opaque dark green
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEffect(),
            const SizedBox(height: 10),
            _buildResultTitle(),
            if (winnerCow != null) ...[
              const SizedBox(height: 6),
              Text(
                '🏆 ${winnerCow.label} về đích đầu tiên!',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
            const SizedBox(height: 10),
            _buildCowBreakdown(),
            const SizedBox(height: 10),
            _buildNetResult(),
            const SizedBox(height: 10),
            _buildPlayAgainButton(),
            if (balance <= 0 && onGetFreeCoins != null)
              TextButton(
                onPressed: onGetFreeCoins,
                child: const Text(
                  'Nhận 1000 coins miễn phí',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffect() {
    return Image.asset(
      _didWin
          ? 'assets/images/win_effect.png'
          : 'assets/images/lose_effect.png',
      height: 100,
      errorBuilder: (_, _, _) =>
          Text(_didWin ? '🎉' : '💸', style: const TextStyle(fontSize: 72)),
    );
  }

  Widget _buildResultTitle() {
    return Text(
      _didWin ? 'THẮNG!' : 'THUA!',
      style: TextStyle(
        color: _didWin ? Colors.amber : Colors.redAccent,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 6,
      ),
    );
  }

  Widget _buildCowBreakdown() {
    return Row(
      children: List.generate(cows.length, (i) {
        final cow = cows[i];
        final bet = confirmedBets[i] ?? 0;
        final isWinner = i == winnerIndex;
        final cowPayout = (isWinner && bet > 0)
            ? (bet * kMultiplier).round()
            : 0;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: isWinner
                  ? Colors.amber.withAlpha(30)
                  : Colors.white.withAlpha(8),
              border: Border.all(
                color: isWinner ? Colors.amber : Colors.white24,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Image.asset(
                  cow.idleFrame,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      Container(width: 56, height: 56, color: cow.color),
                ),
                const SizedBox(height: 4),
                Text(
                  cow.label,
                  style: TextStyle(
                    color: isWinner ? Colors.amber : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (bet > 0) ...[
                  Text(
                    'Cược: $bet xu',
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                  Text(
                    cowPayout > 0 ? '+$cowPayout xu' : '-$bet xu',
                    style: TextStyle(
                      color: cowPayout > 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  const Text(
                    '—',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNetResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _netResult >= 0 ? 'Lãi: +$_netResult xu' : 'Lỗ: $_netResult xu',
            style: TextStyle(
              color: _netResult >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Số dư: $balance xu',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayAgainButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: balance > 0 ? onPlayAgain : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          balance > 0 ? 'CHƠI LẠI' : 'HẾT TIỀN 😭',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
