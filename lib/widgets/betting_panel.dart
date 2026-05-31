import 'package:flutter/material.dart';
import '../models/cow_data.dart';
import 'bet_card.dart';

class BettingPanel extends StatelessWidget {
  final GamePhase phase;
  final List<CowData> cows;
  final List<int> betAmounts;
  final Map<int, int> confirmedBets;
  final int balance;
  final int totalEntered;
  final VoidCallback onStartRace;
  final void Function(int index) onIncrease;
  final void Function(int index) onDecrease;

  const BettingPanel({
    super.key,
    required this.phase,
    required this.cows,
    required this.betAmounts,
    required this.confirmedBets,
    required this.balance,
    required this.totalEntered,
    required this.onStartRace,
    required this.onIncrease,
    required this.onDecrease,
  });

  bool get _isBetting => phase == GamePhase.betting;

  int get _total =>
      _isBetting ? totalEntered : confirmedBets.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D2B0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(),
          const SizedBox(height: 8),
          _buildCowCards(),
          const SizedBox(height: 8),
          _buildSummaryRow(context),
          const SizedBox(height: 8),
          if (_isBetting) _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _isBetting ? 'ĐẶT CƯỢC (có thể chọn nhiều bò)' : '🏁 ĐANG ĐUA...',
      style: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: _isBetting ? 0.5 : 1,
      ),
    );
  }

  Widget _buildCowCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(cows.length, (i) {
        final confirmed = confirmedBets[i] ?? 0;
        return Expanded(
          child: BetCard(
            cow: cows[i],
            isBetting: _isBetting,
            betAmount: betAmounts[i],
            confirmedAmount: confirmed,
            onIncrease: (_isBetting && totalEntered + 10 <= balance)
                ? () => onIncrease(i)
                : null,
            onDecrease: (_isBetting && betAmounts[i] >= 10)
                ? () => onDecrease(i)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/coin.png',
            width: 16,
            height: 16,
            errorBuilder: (_, _, _) => const Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Tổng cược: $_total xu',
            style: TextStyle(
              color: _total > 0 ? Colors.amber : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isBetting)
            Text(
              'Số dư: $balance xu',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: GestureDetector(
        onTap: onStartRace,
        child: Image.asset(
          'assets/images/start_button.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => ElevatedButton(
            onPressed: onStartRace,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'START',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
