import 'package:dio/dio.dart';

/// Erro normalizado da API. Converte o corpo padrão do NestJS
/// (`{ message, error, statusCode }`, onde `message` é string ou lista)
/// numa mensagem única legível.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isNetwork = false});

  final String message;
  final int? statusCode;
  final bool isNetwork;

  bool get isNotFound => statusCode == 404;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Tempo de conexão esgotado. Verifique se a API está no ar.',
          isNetwork: true,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Não foi possível falar com a API em ${e.requestOptions.baseUrl}.',
          isNetwork: true,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          _extractMessage(e.response?.data) ??
              'A API respondeu ${e.response?.statusCode}.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException('Requisição cancelada.');
      default:
        return ApiException(
          e.message ?? 'Falha inesperada na requisição.',
          isNetwork: true,
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty) return m.join(' · ');
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
