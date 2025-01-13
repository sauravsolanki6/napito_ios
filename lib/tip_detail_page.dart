import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/full_image.dart';
import 'package:ms_salon_task/homepageapi_models/health_tips.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TipDetailPage extends StatefulWidget {
  final Tip tip;

  TipDetailPage({required this.tip});

  @override
  _TipDetailPageState createState() => _TipDetailPageState();
}

class _TipDetailPageState extends State<TipDetailPage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false; // New loading state

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true; // Set loading to true while refreshing
    });
    await Future.delayed(const Duration(seconds: 2));
    // Reload data here if needed, then set loading to false
    setState(() {
      _isLoading = false; // Set loading to false after loading data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Tip Details',
          style: GoogleFonts.lato(),
        ),
        backgroundColor: CustomColors.backgroundLight,
      ),
      backgroundColor: CustomColors.backgroundPrimary,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading || widget.tip.allImages.isEmpty
                ? _buildSkeletonLoader() // Show skeleton loader while loading or if no images
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSlider(),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(
                            16.0), // Add padding for better spacing
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey, width: 2), // Blue border
                          borderRadius: BorderRadius.circular(
                              8.0), // Optional: rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Align children to the start
                          children: [
                            Text(
                              widget.tip.title,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                                color: CustomColors.backgroundtext,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    8.0), // Add some space between title and description
                            Html(
                              data: widget.tip.description,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(17),
                                  color: const Color(0xFF333333),
                                  textAlign:
                                      TextAlign.start, // Align text to start
                                ),
                                "*": Style(),
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.tip.extraTips.isNotEmpty) ...[
                        Text(
                          'Extra Tips:',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: CustomColors.backgroundtext,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.tip.extraTips.map((extraTip) {
                          return Column(
                            children: [
                              CustomCollapsibleItem(extraTip: extraTip),
                              const SizedBox(
                                  height: 12), // Add gap between items
                            ],
                          );
                        }).toList(),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Column(
      children: [
        Container(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.tip.allImages.length,
            itemBuilder: (context, index) {
              final imagePath = widget.tip.allImages[index].path;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenImagePage(imagePath: imagePath),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.tip.allImages.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: CustomColors.backgroundtext,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: const Color(0xFFDDDDDD),
                  width: 1.0,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class CustomCollapsibleItem extends StatefulWidget {
  final ExtraTip extraTip;

  CustomCollapsibleItem({required this.extraTip});

  @override
  _CustomCollapsibleItemState createState() => _CustomCollapsibleItemState();
}

class _CustomCollapsibleItemState extends State<CustomCollapsibleItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F3FF),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: CustomColors.backgroundtext, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.extraTip.itemName,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: CustomColors.backgroundtext,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: CustomColors.backgroundtext,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? null : 0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Html(
              data: widget.extraTip.description,
              style: {
                "*": Style(
                  fontSize: FontSize(16),
                  color: const Color(0xFF333333),
                ),
              },
            ),
          ),
        ),
      ],
    );
  }
}
