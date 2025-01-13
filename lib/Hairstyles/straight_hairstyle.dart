import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Hairstyles/hairstyles.dart';
import 'package:ms_salon_task/Hairstyles/portfolio.dart';

class StraightHairstylePage extends StatefulWidget {
  @override
  _StraightHairstylePageState createState() => _StraightHairstylePageState();
}

class _StraightHairstylePageState extends State<StraightHairstylePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.1;

    return Scaffold(
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
              'Hairstyles',
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize:
            MainAxisSize.min, // Ensure the Column takes minimum space necessary
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CustomColors.backgroundtext,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x00000008),
                  offset: Offset(15, 15),
                  blurRadius: 90,
                  spreadRadius: 4,
                ),
              ],
            ),
            height: containerHeight * 0.5,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HairstylesPage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColors.backgroundtext,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Ready Pic',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PortfolioPage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Portfolio',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: CustomColors.backgroundtext,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Container(
              height: 1,
              width: screenWidth * 0.9,
              color: Colors.grey[300],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: screenWidth > 600 ? 4 : 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              padding: EdgeInsets.all(8.0),
              children: List.generate(
                8, // Generating 8 items now
                (index) => GestureDetector(
                  onTap: () {
                    _showImage(index); // Function to show image in larger view
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(index % 2 == 0
                            ? 'assets/hairstyles2.jpg'
                            : 'assets/hairstyles3.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImage(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(index % 2 == 0
                    ? 'assets/hairstyles2.jpg'
                    : 'assets/hairstyles3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
