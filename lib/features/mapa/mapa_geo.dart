import 'package:latlong2/latlong.dart';

import '../../shared/models/poste.dart';

/// Parâmetros geográficos de Itaguari, GO (rede fixa do mock — PRD §3).
abstract final class MapaGeo {
  /// Centro aproximado da cidade, entre os postes do seed.
  static const LatLng centroItaguari = LatLng(-15.9535, -49.5928);

  static const double zoomInicial = 15.2;
  static const double zoomMin = 12;
  static const double zoomMax = 18.5;

  static const String tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String tileUserAgent = 'br.gov.itaguari.smartcity_app';
  static const String atribuicao = '© OpenStreetMap';
}

extension PosteLatLng on PosteResumo {
  LatLng get posicao => LatLng(latitude, longitude);
}
