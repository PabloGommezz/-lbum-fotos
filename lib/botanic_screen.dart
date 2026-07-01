// lib/screens/themes/botanica_screen.dart

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

class BotanicaScreen extends StatefulWidget {
  final Album album;
  const BotanicaScreen({super.key, required this.album});

  @override
  State<BotanicaScreen> createState() => _BotanicaScreenState();
}

class _BotanicaScreenState extends State<BotanicaScreen> {
  static const _bg = Color(0xFFF5EDD6);
  static const _green = Color(0xFF4A5E3A);
  static const _gold = Color(0xFFB8860B);
  static const _brown = Color(0xFF6B4F3A);

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty && mounted) {
      await context.read<AlbumProvider>().addPhotos(
            widget.album.id,
            files.map((f) => f.path).toList(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.album.photos;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // Botanical AppBar
          SliverAppBar(
            expandedHeight: 180,
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: _brown),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined,
                    color: _brown),
                onPressed: _pickImages,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _BotanicaHeader(
                title: widget.album.title,
                subtitle: widget.album.description,
                photoCount: photos.length,
              ),
            ),
          ),

          if (photos.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildPageLayout(i, photos),
                  childCount: (photos.length / 3).ceil(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        backgroundColor: _green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  Widget _buildPageLayout(int pageIndex, List<PhotoItem> photos) {
    final startIdx = pageIndex * 3;
    final endIdx = min(startIdx + 3, photos.length);
    final pagePhotos = photos.sublist(startIdx, endIdx);
    final isEvenPage = pageIndex % 2 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Decorative separator
          if (pageIndex > 0) _buildSeparator(pageIndex),
          const SizedBox(height: 16),

          // Page layout varies by pattern
          if (pagePhotos.length == 1)
            _buildSingleLayout(pagePhotos[0])
          else if (pagePhotos.length == 2)
            _buildDuoLayout(pagePhotos, isEvenPage)
          else
            _buildTrioLayout(pagePhotos, isEvenPage),
        ],
      ),
    ).animate(delay: Duration(milliseconds: pageIndex * 100)).fadeIn();
  }

  Widget _buildSingleLayout(PhotoItem photo) {
    return Transform.rotate(
      angle: photo.rotation,
      child: _BotanicaPhotoFrame(
        photo: photo,
        albumId: widget.album.id,
        height: 320,
        decorationSide: 'left',
      ),
    );
  }

  Widget _buildDuoLayout(List<PhotoItem> photos, bool isEven) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Transform.rotate(
            angle: photos[0].rotation,
            child: _BotanicaPhotoFrame(
              photo: photos[0],
              albumId: widget.album.id,
              height: isEven ? 200 : 240,
              decorationSide: 'right',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isEven ? 32 : 0),
            child: Transform.rotate(
              angle: photos[1].rotation,
              child: _BotanicaPhotoFrame(
                photo: photos[1],
                albumId: widget.album.id,
                height: isEven ? 240 : 200,
                decorationSide: 'left',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrioLayout(List<PhotoItem> photos, bool isEven) {
    return Column(
      children: [
        _buildDuoLayout([photos[0], photos[1]], isEven),
        const SizedBox(height: 12),
        _buildSingleLayout(photos[2]),
      ],
    );
  }

  Widget _buildSeparator(int pageIndex) {
    final decorations = ['❧', '✿', '❦', '✾', '❋'];
    final deco = decorations[pageIndex % decorations.length];
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bg, _gold.withOpacity(0.6), _bg],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            deco,
            style: TextStyle(color: _gold, fontSize: 18),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bg, _gold.withOpacity(0.6), _bg],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌿', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Tu jardín de memorias\nestá esperando',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: _green,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Añadir fotografías'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotanicaHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int photoCount;

  const _BotanicaHeader({
    required this.title,
    this.subtitle,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5EDD6),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A1F14),
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF6B4F3A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5E3A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4A5E3A).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$photoCount fotos',
                  style: const TextStyle(
                    color: Color(0xFF4A5E3A),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotanicaPhotoFrame extends StatelessWidget {
  final PhotoItem photo;
  final String albumId;
  final double height;
  final String decorationSide;

  const _BotanicaPhotoFrame({
    required this.photo,
    required this.albumId,
    required this.height,
    required this.decorationSide,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      onLongPress: () => _showDeleteOption(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              child: SizedBox(
                height: height,
                child: _buildImage(),
              ),
            ),
            // Caption area
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo.caption != null && photo.caption!.isNotEmpty)
                    Text(
                      photo.caption!,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF6B4F3A),
                      ),
                      maxLines: 2,
                    )
                  else
                    // Decorative line
                    Container(
                      height: 1,
                      width: 40,
                      color:
                          const Color(0xFFB8860B).withOpacity(0.4),
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
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
      color: const Color(0xFFE8DEC8),
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
        accentColor: const Color(0xFF4A5E3A),
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Quieres eliminar esta foto del álbum?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AlbumProvider>()
                  .removePhoto(albumId, photo.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}