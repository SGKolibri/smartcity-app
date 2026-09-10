import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';

/// Selo "AO VIVO" com ponto pulsante. Usado no detalhe do poste e no mapa
/// quando o WebSocket está conectado (fase 5).
class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key, this.active = true, this.label = 'AO VIVO'});

  final bool active;
  final String label;

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(LiveIndicator old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? BrutColors.statusFalha : BrutColors.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BrutSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: BrutColors.surface,
        border: Border.all(color: color, width: BrutStroke.thin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: widget.active
                ? Tween(begin: 0.3, end: 1.0).animate(_c)
                : const AlwaysStoppedAnimation(0.5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: BrutSpacing.sm),
          Text(
            widget.active ? widget.label : 'OFFLINE',
            style: BrutType.mono(
              10,
              weight: FontWeight.w700,
              color: BrutColors.ink,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
