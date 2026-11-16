import 'dart:async';

import 'package:flutter/material.dart';

import 'secondary_button.dart';

/// An outlined button that can only be used once per [cooldown], for
/// example "Resend email".
///
/// While waiting it is faded and counts down: "Resend email in 0:42".
/// The wait stops the email service from blocking the user for asking
/// too often.
class CooldownButton extends StatefulWidget {
  const CooldownButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.cooldown = const Duration(seconds: 60),
    this.startCoolingDown = true,
  });

  final String label;

  /// Runs on tap; the countdown restarts when it finishes.
  final Future<void> Function() onPressed;
  final Duration cooldown;

  /// True when something was just sent, so the wait starts right away.
  final bool startCoolingDown;

  @override
  State<CooldownButton> createState() => _CooldownButtonState();
}

class _CooldownButtonState extends State<CooldownButton> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.startCoolingDown) _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = widget.cooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _handleTap() async {
    setState(() => _busy = true);
    try {
      await widget.onPressed();
      if (mounted) _startCountdown();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _secondsLeft > 0;
    final minutes = _secondsLeft ~/ 60;
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return SecondaryButton(
      compact: true,
      label: waiting ? '${widget.label} in $minutes:$seconds' : widget.label,
      onPressed: waiting || _busy ? null : _handleTap,
    );
  }
}
