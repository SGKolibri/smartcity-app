import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Instância única do cliente HTTP para toda a árvore de widgets.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
