import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../../mapa/mapa_providers.dart';
import '../../shell/shell_providers.dart';
import '../detalhe_providers.dart';

/// Barra de ações do detalhe (PRD §5.2): "Agendar manutenção" /
/// "Retomar operação" (`PATCH /postes/:id/status`) e "Ver no mapa".
/// Quando o poste está em falha, a ação de manutenção ganha destaque.
class AcoesPoste extends ConsumerStatefulWidget {
  const AcoesPoste({super.key, required this.poste});

  final Poste poste;

  @override
  ConsumerState<AcoesPoste> createState() => _AcoesPosteState();
}

class _AcoesPosteState extends ConsumerState<AcoesPoste> {
  bool _salvando = false;

  Poste get poste => widget.poste;

  Future<void> _alterarStatus(StatusPoste alvo) async {
    setState(() => _salvando = true);
    try {
      final atualizado = await alterarStatusPoste(ref, poste.id, alvo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alvo == StatusPoste.manutencao
                ? '${atualizado.codigo} entrou em manutenção.'
                : '${atualizado.codigo} voltou a operar.',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _verNoMapa() {
    ref.read(posteSelecionadoProvider.notifier).selecionar(poste.id);
    ref.read(homeTabProvider.notifier).ir(HomeTab.mapa);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final emManutencao = poste.status == StatusPoste.manutencao;
    final emFalha = poste.status == StatusPoste.falhaOffline;

    final botaoStatus = BrutButton(
      label: emManutencao ? 'Retomar operação' : 'Agendar manutenção',
      icon: emManutencao ? Icons.play_arrow : Icons.build,
      loading: _salvando,
      variant: emManutencao
          ? BrutButtonVariant.primary
          : (emFalha
              ? BrutButtonVariant.danger
              : BrutButtonVariant.secondary),
      expand: true,
      onPressed: _salvando
          ? null
          : () => _alterarStatus(
                emManutencao ? StatusPoste.normal : StatusPoste.manutencao,
              ),
    );

    final botaoMapa = BrutButton(
      label: 'Ver no mapa',
      icon: Icons.map,
      variant: emFalha ? BrutButtonVariant.secondary : BrutButtonVariant.primary,
      expand: true,
      onPressed: _salvando ? null : _verNoMapa,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        BrutSpacing.lg,
        BrutSpacing.md,
        BrutSpacing.lg,
        BrutSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: BrutColors.surface,
        border: Border(
          top: BorderSide(color: BrutColors.line, width: BrutStroke.bold),
        ),
      ),
      // Ações empilhadas: sempre cabem em largura de celular. Em falha, a
      // manutenção vem primeiro (priorizada).
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: emFalha
            ? [
                botaoStatus,
                const SizedBox(height: BrutSpacing.sm),
                botaoMapa,
              ]
            : [
                botaoMapa,
                const SizedBox(height: BrutSpacing.sm),
                botaoStatus,
              ],
      ),
    );
  }
}
