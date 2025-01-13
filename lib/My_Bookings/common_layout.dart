import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final String pageTitle;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Widget bodyContent;

  CommonLayout({
    required this.pageTitle,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.bodyContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToggleButton('Upcoming', 'Upcoming'),
              _buildToggleButton('Completed', 'Completed'),
              _buildToggleButton('Cancelled', 'Cancelled'),
            ],
          ),
        ),
      ),
      body: bodyContent,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Handle navigation to Home
              },
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                // Handle navigation to Calendar
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Handle navigation to Notifications
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Handle navigation to Profile
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, String category) {
    return ElevatedButton(
      onPressed: () => onCategorySelected(category),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedCategory == category ? Colors.blue : Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
