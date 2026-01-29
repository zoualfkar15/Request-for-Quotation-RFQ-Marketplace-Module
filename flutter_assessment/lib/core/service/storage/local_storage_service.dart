import 'package:get_storage/get_storage.dart';

import '../../constant/storage_keys.dart';

class LocalStorageService {
  final GetStorage _box = GetStorage();

  String? get accessToken => _box.read<String>(StorageKeys.accessToken);
  String? get refreshToken => _box.read<String>(StorageKeys.refreshToken);
  String? get userRole => _box.read<String>(StorageKeys.userRole);
  int? get userId => _box.read<int>(StorageKeys.userId);

  Future<void> setAuth({
    required String accessToken,
    required String refreshToken,
    required String role,
    required int userId,
  }) async {
    await _box.write(StorageKeys.accessToken, accessToken);
    await _box.write(StorageKeys.refreshToken, refreshToken);
    await _box.write(StorageKeys.userRole, role);
    await _box.write(StorageKeys.userId, userId);
  }

  Future<void> clearAuth() async {
    await _box.remove(StorageKeys.accessToken);
    await _box.remove(StorageKeys.refreshToken);
    await _box.remove(StorageKeys.userRole);
    await _box.remove(StorageKeys.userId);
  }
}


