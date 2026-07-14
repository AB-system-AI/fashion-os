import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

/// Current network state snapshot.
class NetworkState extends Equatable {
  const NetworkState({
    required this.isOnline,
    required this.connectionType,
    required this.quality,
    this.isCaptivePortal = false,
  });

  final bool isOnline;
  final NetworkConnectionType connectionType;
  final NetworkQuality quality;
  final bool isCaptivePortal;

  static const offline = NetworkState(
    isOnline: false,
    connectionType: NetworkConnectionType.offline,
    quality: NetworkQuality.offline,
  );

  @override
  List<Object?> get props => [isOnline, connectionType, quality, isCaptivePortal];
}
