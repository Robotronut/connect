// lib/screens/photo_detail_screen.dart (ensure this file exists and is correct)
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag; // Unique tag for Hero animation

  const PhotoDetailScreen({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Hero(
          tag: heroTag,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
          ),
        ),
      ),
    );
  }
}
