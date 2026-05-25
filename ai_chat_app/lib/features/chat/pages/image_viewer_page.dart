import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<String> images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final url = images[index];
          return InteractiveViewer(
            child: Center(
              child: () {
                if (url.startsWith('http://') || url.startsWith('https://')) {
                  return Image.network(url, fit: BoxFit.contain);
                }
                if (url.startsWith('data:')) {
                  return const Icon(Icons.broken_image, color: Colors.white54);
                }
                return Image.file(
                  File(url),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white54),
                );
              }(),
            ),
          );
        },
      ),
    );
  }
}
