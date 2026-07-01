// lib/screens/themes/sakura_journal_screen.dart

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


class SakuraJournalScreen extends StatefulWidget {
  final Album album;
  const SakuraJournalScreen({super.key, required this.album});

  @override
  State<SakuraJournalScreen> createState() => _SakuraJournalScreenState();
}

class _SakuraJournalScreenState extends State<SakuraJournalScreen> {
  static const _bg = Color(0xFFFDF8F8);
  static const _ink = Color(0xFF3D3535);
  static const _pink = Color(0xFFE8A0A8);
  static const _softPink = Color(0xFFF5DCE0);
  static const _sage = Color(0xFF8CA88E);

  final ScrollController _scrollController = ScrollController();

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty && mounted) {
      await context
          .read<AlbumProvider>()
          .addPhotos(widget.album.id, files.map((f) => f.path).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.album.photos;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sakura header
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: _ink),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: _ink),
                onPressed: _pickImages,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _SakuraHeader(
                title: widget.album.title,
                subtitle: widget.album.description,
                photoCount: photos.length,
              ),
            ),
          ),

          // Petals decorative row
          SliverToBoxAdapter(
            child: _buildPetalRow(),
          ),

          // Photos in journal layout
          if (photos.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) =>
                      _buildJournalEntry(photos[i], i, photos.length),
                  childCount: photos.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        backgroundColor: _pink,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  Widget _buildPetalRow() {
    final petals = ['🌸', '✿', '🌸', '✿', '🌸', '✿', '🌸'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: petals
            .map((p) => Text(p,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.3))))
            .toList(),
      ),
    );
  }

  Widget _buildJournalEntry(
      PhotoItem photo, int index, int totalCount) {
    final isRightAligned = index % 3 == 1;
    final isCentered = index % 3 == 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: isCentered
            ? CrossAxisAlignment.center
            : isRightAligned
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          // Watercolor wash behind photo
          GestureDetector(
            onTap: () => _showDetail(photo),
            onLongPress: () => _showDeleteOption(photo),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Watercolor background blob
                CustomPaint(
                  painter: _WatercolorBlobPainter(
                    color: index % 2 == 0 ? _softPink : const Color(0xFFDCEADC),
                    seed: index,
                  ),
                  child: const SizedBox(width: 280, height: 240),
                ),
                // Photo
                Container(
                  width: 240,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImage(photo),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Caption / Journal text
          if (photo.caption != null && photo.caption!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Column(
                crossAxisAlignment: isCentered
                    ? CrossAxisAlignment.center
                    : isRightAligned
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.caption!,
                    textAlign: isCentered
                        ? TextAlign.center
                        : isRightAligned
                            ? TextAlign.right
                            : TextAlign.left,
                    style: GoogleFonts.notoSerif(
                      fontSize: 13,
                      color: _ink.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),

          // Small decorative element
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              index % 3 == 0 ? '— 🌸' : index % 3 == 1 ? '🌿 —' : '• 🌸 •',
              style: TextStyle(
                fontSize: 12,
                color: _pink.withOpacity(0.6),
              ),
            ),
          ),

          // Separator line (except last)
          if (index < totalCount - 1) ...[
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _pink.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildImage(PhotoItem photo) {
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
      color: _softPink,
      child: const Center(
        child: Text('🌸', style: TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter:
                    _WatercolorBlobPainter(color: _softPink, seed: 0),
                child: const SizedBox(width: 160, height: 160),
              ),
              const Text('🌸', style: TextStyle(fontSize: 60)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '花の記憶',
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              color: _ink,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Memorias florales',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: _ink.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _pink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _pink),
              ),
              child: Text(
                'Añadir fotografías',
                style: GoogleFonts.notoSerif(
                  color: _pink,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(PhotoItem photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhotoDetailSheet(
        photo: photo,
        albumId: widget.album.id,
        accentColor: _pink,
      ),
    );
  }

  void _showDeleteOption(PhotoItem photo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Eliminar esta memoria?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AlbumProvider>()
                  .removePhoto(widget.album.id, photo.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _SakuraHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int photoCount;

  const _SakuraHeader({
    required this.title,
    this.subtitle,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDF8F8),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Japanese-style vertical line accent
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 2,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFFE8A0A8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('🌸', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSerif(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF3D3535),
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.notoSerif(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF3D3535).withOpacity(0.5),
                        ),
                      ),
                    Text(
                      '$photoCount memorias',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFFE8A0A8).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WatercolorBlobPainter extends CustomPainter {
  final Color color;
  final int seed;

  const _WatercolorBlobPainter({required this.color, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) * 0.45;

    final path = Path();
    const steps = 8;
    for (int i = 0; i <= steps; i++) {
      final angle = 2 * pi * i / steps;
      final variation = 0.85 + rng.nextDouble() * 0.3;
      final x = cx + r * variation * cos(angle);
      final y = cy + r * variation * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}