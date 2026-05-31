import 'package:flutter/material.dart';
import '../models/cow_data.dart';

/// A single cow card used in the betting panel.
class BetCard extends StatelessWidget {
  final CowData cow;
  final bool isBetting;
  final int betAmount;
  final int confirmedAmount;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const BetCard({
    super.key,
    required this.cow,
    required this.isBetting,
    required this.betAmount,
    required this.confirmedAmount,
    this.onIncrease,
    this.onDecrease,
  });

  bool get _hasBet => isBetting ? betAmount > 0 : confirmedAmount > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: _hasBet ? Colors.amber.withAlpha(30) : Colors.white.withAlpha(8),
        border: Border.all(
          color: _hasBet ? Colors.amber : Colors.white24,
          width: _hasBet ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Cow to-bet image
          Image.asset(
            cow.toBetFrame,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cow.color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Controls (betting) or confirmed label (racing)
          if (isBetting)
            _BetControls(
              amount: betAmount,
              canIncrease: onIncrease != null,
              canDecrease: onDecrease != null,
              onIncrease: onIncrease,
              onDecrease: onDecrease,
              hasBet: _hasBet,
            )
          else
            _ConfirmedLabel(amount: confirmedAmount),
        ],
      ),
    );
  }
}

class _BetControls extends StatelessWidget {
  final int amount;
  final bool canIncrease;
  final bool canDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final bool hasBet;

  const _BetControls({
    required this.amount,
    required this.canIncrease,
    required this.canDecrease,
    required this.hasBet,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.remove,
          enabled: canDecrease,
          enabledColor: Colors.white12,
          enabledBorderColor: Colors.white38,
          enabledIconColor: Colors.white70,
          onTap: onDecrease,
        ),
        const SizedBox(width: 4),
        Text(
          '$amount',
          style: TextStyle(
            color: hasBet ? Colors.amber : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        _CircleButton(
          icon: Icons.add,
          enabled: canIncrease,
          enabledColor: Colors.amber.withAlpha(40),
          enabledBorderColor: Colors.amber,
          enabledIconColor: Colors.amber,
          onTap: onIncrease,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color enabledColor;
  final Color enabledBorderColor;
  final Color enabledIconColor;
  final VoidCallback? onTap;

  const _CircleButton({
    required this.icon,
    required this.enabled,
    required this.enabledColor,
    required this.enabledBorderColor,
    required this.enabledIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: enabled ? enabledColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled ? enabledBorderColor : Colors.white12,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? enabledIconColor : Colors.white24,
        ),
      ),
    );
  }
}

class _ConfirmedLabel extends StatelessWidget {
  final int amount;

  const _ConfirmedLabel({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: amount > 0 ? Colors.amber.withAlpha(40) : Colors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        amount > 0 ? '$amount xu' : 'Không cược',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: amount > 0 ? Colors.amber : Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
