import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  FullScreenImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
        backgroundColor: const Color(0xFFFAFAFA), // AppBar background color
      ),
      backgroundColor:
          const Color(0xFFFFFFFF), // Background color of the entire Scaffold
      body: Container(
        color: Colors.white, // Background color of the PhotoView container
        child: PhotoView(
          imageProvider: NetworkImage(imagePath),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: BoxDecoration(
            color: Colors.white, // Background color of the PhotoView
          ),
        ),
      ),
    );
  }
}
