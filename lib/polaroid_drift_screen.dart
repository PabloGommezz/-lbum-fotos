// lib/screens/themes/polaroid_drift_screen.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_album_app/album_model.dart';
import 'package:photo_album_app/album_provider.dart';
import 'package:photo_album_app/photo_detail_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PolaroidDriftScreen extends StatefulWidget {
  final Album album;
  const PolaroidDriftScreen({super.key, required this.album});

  @override
  State<PolaroidDriftScreen> createState() => _PolaroidDriftScreenState();
}

class _PolaroidDriftScreenState extends State<PolaroidDriftScreen> {
  static const _bg = Color(0xFFFAF7F2);
  static const _dark = Color(0xFF2C2C2C);
  static const _orange = Color(0xFFFF6B35);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty && mounted) {
      await context
          .read<AlbumProvider>()
          .addPhotos(widget.album.id, files.map((f) => f.path).toList());
    }
  }

  List<List<PhotoItem>> _groupPhotos(List<PhotoItem> photos) {
    final pages = <List<PhotoItem>>[];
    for (int i = 0; i < photos.length; i += 4) {
      pages.add(photos.sublist(i, min(i + 4, photos.length)));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.album.photos;
    final pages = _groupPhotos(photos);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Subtle texture overlay
          Positioned.fill(
            child: CustomPaint(painter: _DotTexturePainter()),
          ),

          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: _dark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.album.title.toUpperCase(),
                              style: GoogleFonts.specialElite(
                                fontSize: 16,
                                color: _dark,
                                letterSpacing: 3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.album.description != null)
                              Text(
                                widget.album.description!,
                                style: GoogleFonts.specialElite(
                                  fontSize: 11,
                                  color: _dark.withOpacity(0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: _dark),
                        onPressed: _pickImages,
                      ),
                    ],
                  ),
                ),
              ),

              // Film strip indicator
              _buildFilmStrip(photos.length),

              // Page view
              Expanded(
                child: photos.isEmpty
                    ? _buildEmpty()
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) =>
                            setState(() => _currentPage = i),
                        itemCount: pages.length,
                        itemBuilder: (ctx, i) =>
                            _buildPage(pages[i], i),
                      ),
              ),

              // Page indicator
              if (pages.length > 1) ...[
                const SizedBox(height: 16),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages.length,
                  effect: WormEffect(
                    dotColor: _dark.withOpacity(0.2),
                    activeDotColor: _orange,
                    dotHeight: 6,
                    dotWidth: 6,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        mini: true,
        child: const Icon(Icons.add_a_photo_outlined, size: 20),
      ),
    );
  }

  Widget _buildFilmStrip(int count) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Left sprockets
          _buildSprockets(),
          // Film content
          Expanded(
            child: Container(
              color: _dark,
              child: Center(
                child: Text(
                  '${count} EXPOSURES',
                  style: GoogleFonts.specialElite(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),
          // Right sprockets
          _buildSprockets(),
        ],
      ),
    );
  }

  Widget _buildSprockets() {
    return Container(
      width: 24,
      color: _dark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          2,
          (_) => Container(
            width: 10,
            height: 8,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(List<PhotoItem> photos, int pageIndex) {
    final layouts = [
      _buildLayout1,
      _buildLayout2,
      _buildLayout3,
    ];
    final layoutFn = layouts[pageIndex % layouts.length];
    return layoutFn(photos);
  }

  Widget _buildLayout1(List<PhotoItem> photos) {
    // Scattered layout
    return Padding(
      padding: const EdgeInsets.all(24),
      child: photos.length == 1
          ? Center(
              child: _PolaroidPhoto(
                photo: photos[0],
                albumId: widget.album.id,
                size: 280,
              ),
            )
          : Wrap(
              spacing: -20,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: photos
                  .map((p) => _PolaroidPhoto(
                        photo: p,
                        albumId: widget.album.id,
                        size: photos.length <= 2 ? 200 : 160,
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildLayout2(List<PhotoItem> photos) {
    // Grid with one big photo
    if (photos.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PolaroidPhoto(
            photo: photos[0],
            albumId: widget.album.id,
            size: 220,
          ),
          if (photos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: photos
                  .skip(1)
                  .map((p) => _PolaroidPhoto(
                        photo: p,
                        albumId: widget.album.id,
                        size: 150,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLayout3(List<PhotoItem> photos) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: photos
              .map((p) => _PolaroidPhoto(
                    photo: p,
                    albumId: widget.album.id,
                    size: 175,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(3, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    color: const Color(0xFFE8E0D0),
                    child: const Center(
                      child: Icon(Icons.add_photo_alternate_outlined,
                          color: Color(0xFF9E8E72), size: 40),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'tap to add',
                    style: GoogleFonts.specialElite(
                      fontSize: 12,
                      color: _dark.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImages,
            child: Text(
              'AÑADIR FOTOS',
              style: GoogleFonts.specialElite(
                fontSize: 14,
                color: _orange,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolaroidPhoto extends StatelessWidget {
  final PhotoItem photo;
  final String albumId;
  final double size;

  const _PolaroidPhoto({
    required this.photo,
    required this.albumId,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      onLongPress: () => _showDeleteOption(context),
      child: Transform.rotate(
        angle: photo.rotation,
        child: Container(
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(3, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                height: size * 0.78,
                child: _buildImage(),
              ),
              SizedBox(
                height: size * 0.22,
                child: Center(
                  child: photo.caption != null && photo.caption!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            photo.caption!,
                            style: GoogleFonts.specialElite(
                              fontSize: 10,
                              color: const Color(0xFF2C2C2C),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        )
                      : Text(
                          '~ ~ ~',
                          style: GoogleFonts.specialElite(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildImage() {
    if (photo.path.startsWith('/')) {
      return Image.file(File(photo.path),
          fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      color: const Color(0xFFE8E0D0),
      child: const Center(
        child: Icon(Icons.image_outlined,
            color: Color(0xFF9E8E72), size: 32),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhotoDetailSheet(
        photo: photo,
        albumId: albumId,
        accentColor: const Color(0xFFFF6B35),
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Quieres eliminar esta foto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AlbumProvider>().removePhoto(albumId, photo.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DotTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C2C2C).withOpacity(0.03)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      for (double y = 0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}