// lib/screens/themes/noir_cinema_screen.dart

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

class NoirCinemaScreen extends StatefulWidget {
  final Album album;
  const NoirCinemaScreen({super.key, required this.album});

  @override
  State<NoirCinemaScreen> createState() => _NoirCinemaScreenState();
}

class _NoirCinemaScreenState extends State<NoirCinemaScreen> {
  static const _bg = Color(0xFF0D0D0D);
  static const _cream = Color(0xFFE8E0D0);
  static const _gold = Color(0xFFD4AF37);
  static const _dim = Color(0xFF1A1A1A);

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
    for (int i = 0; i < photos.length; i += 3) {
      pages.add(photos.sublist(i, min(i + 3, photos.length)));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.album.photos;
    final pages = _groupPhotos(photos);

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // Cinematic header
          _buildCinematicHeader(context),

          // Film reel top border
          _buildFilmReelBorder(),

          // Content
          Expanded(
            child: photos.isEmpty
                ? _buildEmpty()
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) =>
                        setState(() => _currentPage = i),
                    itemCount: pages.length,
                    itemBuilder: (ctx, i) =>
                        _buildCinemaPage(pages[i], i),
                  ),
          ),

          // Film reel bottom border
          _buildFilmReelBorder(),

          // Page indicator & controls
          _buildBottomBar(pages.length),
        ],
      ),
    );
  }

  Widget _buildCinematicHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: _gold),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.album.title.toUpperCase(),
                    style: GoogleFonts.bebasNeue(
                      fontSize: 22,
                      color: _cream,
                      letterSpacing: 6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 2),
                    color: _gold.withOpacity(0.5),
                  ),
                  Text(
                    'ÁLBUM CINEMATOGRÁFICO',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 10,
                      color: _gold.withOpacity(0.7),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: _gold),
              onPressed: _pickImages,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmReelBorder() {
    return SizedBox(
      height: 20,
      child: Row(
        children: List.generate(
          30,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                color: i % 2 == 0 ? _dim : Colors.transparent,
                border: i % 2 == 0
                    ? Border.all(
                        color: _gold.withOpacity(0.2), width: 0.5)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaPage(List<PhotoItem> photos, int pageIndex) {
    if (photos.isEmpty) return const SizedBox();

    final layouts = [
      _buildFullBleedLayout,
      _buildSplitLayout,
      _buildTriangleLayout,
    ];

    return layouts[pageIndex % layouts.length](photos);
  }

  Widget _buildFullBleedLayout(List<PhotoItem> photos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: photos.asMap().entries.map((e) {
          final aspectRatios = [16 / 9, 4 / 3, 21 / 9];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _NoirFrame(
                photo: e.value,
                albumId: widget.album.id,
                frameNumber: e.key + 1,
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSplitLayout(List<PhotoItem> photos) {
    if (photos.length == 1) return _buildFullBleedLayout(photos);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: _NoirFrame(
              photo: photos[0],
              albumId: widget.album.id,
              frameNumber: 1,
            ),
          ),
          const SizedBox(height: 8),
          if (photos.length > 1)
            Expanded(
              flex: 2,
              child: Row(
                children: photos.skip(1).map((p) {
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: _NoirFrame(
                        photo: p,
                        albumId: widget.album.id,
                        frameNumber: photos.indexOf(p) + 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildTriangleLayout(List<PhotoItem> photos) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _NoirFrame(
                    photo: photos[0],
                    albumId: widget.album.id,
                    frameNumber: 1,
                  ),
                ),
                if (photos.length > 2) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    child: _NoirFrame(
                      photo: photos[2],
                      albumId: widget.album.id,
                      frameNumber: 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (photos.length > 1)
            Expanded(
              child: _NoirFrame(
                photo: photos[1],
                albumId: widget.album.id,
                frameNumber: 2,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: _gold, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.movie_filter_outlined,
                  color: Color(0xFF4A4A4A), size: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ESCENA VACÍA',
            style: GoogleFonts.bebasNeue(
              fontSize: 22,
              color: _cream,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tus primeras escenas',
            style: GoogleFonts.bebasNeue(
              fontSize: 14,
              color: _gold.withOpacity(0.7),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: _gold),
              ),
              child: Text(
                'AÑADIR FOTOS',
                style: GoogleFonts.bebasNeue(
                  color: _gold,
                  letterSpacing: 4,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int pageCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.album.photos.length} FRAMES',
            style: GoogleFonts.bebasNeue(
              color: _gold.withOpacity(0.7),
              letterSpacing: 3,
              fontSize: 12,
            ),
          ),
          if (pageCount > 1)
            SmoothPageIndicator(
              controller: _pageController,
              count: pageCount,
              effect: ExpandingDotsEffect(
                dotColor: _cream.withOpacity(0.2),
                activeDotColor: _gold,
                dotHeight: 4,
                dotWidth: 4,
                expansionFactor: 4,
              ),
            ),
          Text(
            '${_currentPage + 1}/${pageCount}',
            style: GoogleFonts.bebasNeue(
              color: _gold.withOpacity(0.7),
              letterSpacing: 3,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoirFrame extends StatelessWidget {
  final PhotoItem photo;
  final String albumId;
  final int frameNumber;

  const _NoirFrame({
    required this.photo,
    required this.albumId,
    required this.frameNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      onLongPress: () => _showDeleteOption(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo with slight desaturation effect
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.8, 0.1, 0.1, 0, 0,
                0.1, 0.8, 0.1, 0, 0,
                0.1, 0.1, 0.8, 0, 0,
                0,   0,   0,   1, 0,
              ]),
              child: _buildImage(),
            ),

            // Frame number overlay
            Positioned(
              top: 6,
              left: 8,
              child: Text(
                'FRAME ${frameNumber.toString().padLeft(2, '0')}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 9,
                  color: const Color(0xFFD4AF37).withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
            ),

            // Caption overlay at bottom
            if (photo.caption != null && photo.caption!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    photo.caption!,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 11,
                      color: const Color(0xFFE8E0D0),
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // Corner marks (cinematographic)
            ..._buildCornerMarks(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarks() {
    const color = Color(0xFFD4AF37);
    const size = 8.0;
    const thickness = 1.0;

    return [
      Positioned(
          top: 0,
          left: 0,
          child: _corner(color, size, thickness,
              horizontal: Alignment.centerLeft,
              vertical: Alignment.topCenter)),
      Positioned(
          top: 0,
          right: 0,
          child: _corner(color, size, thickness,
              horizontal: Alignment.centerRight,
              vertical: Alignment.topCenter)),
      Positioned(
          bottom: 0,
          left: 0,
          child: _corner(color, size, thickness,
              horizontal: Alignment.centerLeft,
              vertical: Alignment.bottomCenter)),
      Positioned(
          bottom: 0,
          right: 0,
          child: _corner(color, size, thickness,
              horizontal: Alignment.centerRight,
              vertical: Alignment.bottomCenter)),
    ];
  }

  Widget _corner(Color color, double size, double thickness,
      {required Alignment horizontal, required Alignment vertical}) {
    return SizedBox(
      width: size * 1.5,
      height: size * 1.5,
      child: Stack(
        children: [
          Align(
            alignment: horizontal,
            child: Container(width: thickness, height: size, color: color),
          ),
          Align(
            alignment: vertical,
            child: Container(width: size, height: thickness, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (photo.path.startsWith('/')) {
      return Image.file(
        File(photo.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: Icon(Icons.image_outlined,
            color: Color(0xFF4A4A4A), size: 32),
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
        accentColor: const Color(0xFFD4AF37),
        isDark: true,
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar frame',
            style: TextStyle(color: Color(0xFFE8E0D0))),
        content: const Text('¿Eliminar esta foto?',
            style: TextStyle(color: Color(0xFFE8E0D0))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar',
                  style: TextStyle(
                      color: const Color(0xFFD4AF37).withOpacity(0.7)))),
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