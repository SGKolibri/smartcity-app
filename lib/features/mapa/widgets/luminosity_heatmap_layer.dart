import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../shared/models/models.dart';
import '../mapa_geo.dart';

/// Camada de heatmap de luminosidade (PRD §5.1) desenhada por cima do mapa.
///
/// Overlay customizado (sem plugin): projeta cada poste para pixels da tela via
/// a [MapCamera] e pinta um borrão radial cuja cor varia de ~50% (piso, azul
/// escuro) a 100% (pico, amarelo). Os borrões acumulam com [BlendMode.plus].
class LuminosityHeatmapLayer extends StatelessWidget {
  const LuminosityHeatmapLayer({super.key, required this.postes});

  final List<PosteResumo> postes;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _HeatPainter(camera: camera, postes: postes),
      ),
    );
  }
}

class _HeatPainter extends CustomPainter {
  _HeatPainter({required this.camera, required this.postes});

  final MapCamera camera;
  final List<PosteResumo> postes;

  @override
  void paint(Canvas canvas, Size size) {
    // Raio do borrão cresce com o zoom (aprox. dobra a cada nível).
    final exp = (camera.zoom.round() - 13).clamp(0, 6);
    final raio = (14.0 * (1 << exp)).clamp(28.0, 180.0).toDouble();
    final margem = raio * 2;
    final rect = Offset.zero & size;

    canvas.saveLayer(rect, Paint());
    for (final p in postes) {
      // Postes sem luz acesa (manutenção) não contribuem.
      if (p.luminosidadeAtual <= 0) continue;

      final o = camera.latLngToScreenOffset(p.posicao);
      if (o.dx < -margem ||
          o.dy < -margem ||
          o.dx > size.width + margem ||
          o.dy > size.height + margem) {
        continue;
      }

      final t = ((p.luminosidadeAtual - 50) / 50).clamp(0.0, 1.0);
      final cor = Color.lerp(BrutColors.lumBaixa, BrutColors.lumAlta, t)!;

      final paint = Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [cor.withValues(alpha: 0.42), cor.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: o, radius: raio));
      canvas.drawCircle(o, raio, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeatPainter old) =>
      old.camera.center != camera.center ||
      old.camera.zoom != camera.zoom ||
      old.camera.rotation != camera.rotation ||
      !identical(old.postes, postes);
}

/// Legenda 50% → 100% para acompanhar o heatmap.
class HeatmapLegenda extends StatelessWidget {
  const HeatmapLegenda({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: BrutColors.surface,
        border: Border.all(color: BrutColors.line, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('LUMINOSIDADE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: BrutColors.inkMuted,
              )),
          const SizedBox(width: 8),
          const Text('50%', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Container(
            width: 64,
            height: 8,
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(color: BrutColors.line, width: 1),
              ),
              gradient: LinearGradient(
                colors: [BrutColors.lumBaixa, BrutColors.lumMedia, BrutColors.lumAlta],
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text('100%', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
