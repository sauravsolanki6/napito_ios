import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ms_salon_task/printmessage.dart';

class CheckInternetConnection {
  final ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _streamSubscription;
  late String name = "";
  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      PrintMessage.printMessage(
          e.toString(), 'hasNetwork', 'CheckInternetConnection');
      return true;
    }
  }
}
