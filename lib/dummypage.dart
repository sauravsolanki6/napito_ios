import 'package:flutter/material.dart';

class DummyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dummy Page'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text('Card 1'),
              subtitle: Text('This is a dummy card example.'),
            ),
          ),
          SizedBox(height: 10),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text('Card 2'),
              subtitle: Text('This is another dummy card example.'),
            ),
          ),
          SizedBox(height: 10),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text('Card 3'),
              subtitle: Text('This is a third dummy card example.'),
            ),
          ),
        ],
      ),
    );
  }
}
