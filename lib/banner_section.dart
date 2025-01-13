import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';

import 'Colors/custom_colors.dart';

class BannerSection extends StatefulWidget {
  final Future<List<String>> bannersFuture;

  BannerSection({
    required this.bannersFuture,
  });

  @override
  _BannerSectionState createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  late PageController _pageController;
  late Future<List<String>> _bannersFuture;
  late List<String> _banners;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bannersFuture = widget.bannersFuture;
    _pageController = PageController();

    // Start the auto-slide functionality
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first banner
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No banners available'));
        } else {
          _banners = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index; // Update the current page
                    });
                  },
                  children: _banners
                      .map((imageUrl) => ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: _buildBanner(imageUrl),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 10), // Space between PageView and dots
              _buildDots(_banners.length),
            ],
          );
        }
      },
    );
  }

  Widget _buildBanner(String imageUrl) {
    return Image.network(imageUrl, fit: BoxFit.cover);
  }

  Widget _buildDots(int bannerCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        bannerCount,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: _currentPage == index ? 16 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? CustomColors.backgroundtext
                : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
