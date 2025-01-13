import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Reusable widget for each haircut item
class ColorItem extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final String price;
  final String duration;

  const ColorItem({
    Key? key,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 100,
      margin: EdgeInsets.only(left: 0, top: 0), // Adjusted top margin
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0x00000008),
            offset: Offset(15, 15),
            blurRadius: 90,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: -35,
            child: Container(
              width: 200,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: AssetImage(imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 80.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 80.0),
                    child: Text(
                      price,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    CupertinoIcons.stopwatch,
                    size: 16,
                    color: Color(0xFFA1A1A1),
                  ),
                  SizedBox(width: 5),
                  Text(
                    duration,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA1A1A1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Main page widget
class ColorServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0, // Remove elevation
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Color',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            padding: EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 14.4 / 7,
                          color: Color(0xFFC4C4C4),
                        ),
                        border: InputBorder.none,
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Icon(
                            CupertinoIcons.search,
                            size: 20,
                            color: Colors.blue, // Blue color for search icon
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ColorItem(
            imageAsset: 'assets/color1.png',
            title: 'Red Hair Color',
            description: 'Hair is straight across, with no elevation',
            price: '₹150',
            duration: '00:30 min',
          ),
          SizedBox(height: 10),
          ColorItem(
            imageAsset: 'assets/color1.png',
            title: 'Light Brown Hair Color',
            description: 'Lighter than medium brown ',
            price: '₹100',
            duration: '1 hrs, 15 min',
          ),
        ],
      ),
    );
  }
}
