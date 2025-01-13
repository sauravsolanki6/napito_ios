import 'package:flutter/material.dart';
import 'package:ms_salon_task/buttondesign.dart';
import 'package:ms_salon_task/check_internet.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  State createState() => NoInternetConnectionState();
}

class NoInternetConnectionState extends State<NoInternetConnection> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text('No Internet Connection'),
        ),
        body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              Center(
                  child: Image.asset(
                'assets/nointernet.png',
                width: 200.0,
                height: 300.0,
              )),
              const Text(
                'OPPS!!',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const Text(
                'NO INTERNET',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const Text('Please check internet connection'),
              Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(3.0),
                  child: ButtonDesign(
                    onPressed: () {
                      checkInternet();
                    },
                    child: const Text(
                      'REFRESH',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ],
          ),
        ));
  }

  checkInternet() async {
    Future<bool> connection = CheckInternetConnection().hasNetwork();
    if (await connection) {
      Navigator.pop(context);
    }
  }
}
