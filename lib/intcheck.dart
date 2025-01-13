import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheckPage extends StatefulWidget {
  @override
  _InternetCheckPageState createState() => _InternetCheckPageState();
}

class _InternetCheckPageState extends State<InternetCheckPage> {
  bool _isConnected = true; // Track internet connection status

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  // Function to check internet connection
  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Update the _isConnected variable based on the connectivity result
    setState(() {
      if (connectivityResult == ConnectivityResult.none) {
        _isConnected = false;
        _showNoInternetSnackBar();
      } else {
        _isConnected = true;
      }
    });
  }

  // Show SnackBar when there's no internet
  void _showNoInternetSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No internet connection.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Internet Check Page"),
      ),
      body: Center(
        child: _isConnected
            ? Text(
                "You are connected to the internet.",
                style: TextStyle(fontSize: 20),
              )
            : Text(
                "No internet connection.",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
      ),
    );
  }
}
