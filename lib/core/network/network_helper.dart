import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:news_app/utils/error/exceptions.dart';

class NetworkHelper {
  static Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    log('Connectivity result: $connectivityResult');
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw NetworkException('No internet connection, device is offline');
    }

    final result = await InternetAddress.lookup('google.com');
    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      return false;
    }

    return true;
  }
}
