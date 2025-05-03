import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:item_minder_flutterapp/base/managers/sync_manager.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  // Setup a listener for connectivity changes
  void setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        //TODO FIx SyncManager().syncPendingItems(); // Retry when connection is restored
      }
    });
  }

  //Check Connectivity
  Future<bool> get isOnline async {
    var connectivityResult = await Connectivity().checkConnectivity();
    debugPrint('Connectivity result: $connectivityResult');
    return connectivityResult != ConnectivityResult.none;
  }
}
