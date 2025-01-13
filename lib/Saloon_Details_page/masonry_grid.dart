// import 'package:flutter/material.dart';

// // Masonry Grid Item Widget
// class MasonryGridItem extends StatelessWidget {
//   final String imageUrl;
//   final VoidCallback onTap;

//   MasonryGridItem({
//     required this.imageUrl,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(imageUrl),
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//       ),
//     );
//   }
// }

// // Masonry Grid Widget
// class MasonryGrid extends StatelessWidget {
//   final List<String> imageUrls;
//   final int crossAxisCount;
//   final double crossAxisSpacing;
//   final double mainAxisSpacing;

//   MasonryGrid({
//     required this.imageUrls,
//     this.crossAxisCount = 2,
//     this.crossAxisSpacing = 8.0,
//     this.mainAxisSpacing = 8.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> items = imageUrls.map((imageUrl) {
//       return MasonryGridItem(
//         imageUrl: imageUrl,
//         onTap: () {
//           // Implement your image tap logic here
//           print('Tapped on image: $imageUrl');
//         },
//       );
//     }).toList();

//     return CustomScrollView(
//       slivers: [
//         SliverGrid(
//           delegate: SliverChildBuilderDelegate(
//             (context, index) {
//               return Padding(
//                 padding: EdgeInsets.all(4.0),
//                 child: items[index],
//               );
//             },
//             childCount: items.length,
//           ),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             crossAxisSpacing: crossAxisSpacing,
//             mainAxisSpacing: mainAxisSpacing,
//             childAspectRatio: 0.5, // Adjust this ratio as needed
//           ),
//         ),
//       ],
//     );
//   }
// }
