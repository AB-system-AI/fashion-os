import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/security/device_info_service.dart';
import 'package:fashion_pos_enterprise/core/services/local_storage_service.dart';
import 'package:fashion_pos_enterprise/core/services/supabase_service.dart';
import 'package:fashion_pos_enterprise/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService(ref.watch(localStorageServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
    deviceInfo: ref.watch(deviceInfoServiceProvider),
  );
});
