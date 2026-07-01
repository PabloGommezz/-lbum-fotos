// lib/screens/themes/cosmos_screen.dart

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

class CosmosScreen extends StatefulWidget {
  final Album album;
  const CosmosScreen({super.key, required this.album});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF050714);
  static const _purple = Color(0xFF7B61FF);
  static const _lavender = Color(0xFFE8D5FF);
  static const _glow = Color(0xFFB8A0FF);

  late final AnimationController _starsController;
  late final AnimationController _nebulaeController;

  @override
  void initState() {
    super.initState();
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _nebulaeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starsController.dispose();
    _nebulaeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final photos = widget.album.photos;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Animated starfield background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _starsController,
              builder: (_, __) => CustomPaint(
                painter: _StarfieldPainter(_starsController.value),
              ),
            ),
          ),

          // Nebulae effect
          AnimatedBuilder(
            animation: _nebulaeController,
            builder: (_, __) => Positioned.fill(
              child: CustomPaint(
                painter: _NebulaePainter(_nebulaeController.value),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              _buildCosmosHeader(context),
              Expanded(
                child: photos.isEmpty
                    ? _buildEmpty()
                    : _buildGallery(photos),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  Widget _buildCosmosHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: _lavender),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.album.title,
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      color: _lavender,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _purple,
                          boxShadow: [
                            BoxShadow(
                              color: _purple,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.album.photos.length} MEMORIAS',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          color: _glow.withOpacity(0.7),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _purple,
                          boxShadow: [
                            BoxShadow(
                              color: _purple,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: _lavender),
              onPressed: _pickImages,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(List<PhotoItem> photos) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: photos.length,
      itemBuilder: (ctx, i) => _CosmosPhotoCard(
        photo: photos[i],
        albumId: widget.album.id,
        index: i,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_purple, _lavender],
            ).createShader(bounds),
            child: const Text(
              '✦',
              style: TextStyle(fontSize: 80, color: Colors.white),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
              ),
          const SizedBox(height: 24),
          Text(
            'EL UNIVERSO\nTE ESPERA',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              color: _lavender,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tus memorias a las estrellas',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: _glow.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _purple, width: 1.5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                'AÑADIR FOTOS',
                style: GoogleFonts.orbitron(
                  color: _lavender,
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmosPhotoCard extends StatelessWidget {
  final PhotoItem photo;
  final String albumId;
  final int index;

  const _CosmosPhotoCard({
    required this.photo,
    required this.albumId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = index % 5 == 0;

    return GestureDetector(
      onTap: () => _showDetail(context),
      onLongPress: () => _showDeleteOption(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7B61FF).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B61FF).withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              _buildImage(),

              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF050714).withOpacity(0.8),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),

              // Star corner decoration
              Positioned(
                top: 8,
                right: 8,
                child: Text(
                  '✦',
                  style: TextStyle(
                    color: const Color(0xFFE8D5FF).withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ),

              // Caption
              if (photo.caption != null && photo.caption!.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    photo.caption!,
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      color: const Color(0xFFE8D5FF),
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                  ),
                ),
            ],
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: index * 80))
          .fadeIn(duration: 500.ms)
          .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 400.ms),
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
      color: const Color(0xFF0D0D2B),
      child: Center(
        child: Icon(
          Icons.stars_outlined,
          color: const Color(0xFF7B61FF).withOpacity(0.5),
          size: 32,
        ),
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
        accentColor: const Color(0xFF7B61FF),
        isDark: true,
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D2B),
        title: const Text('Eliminar foto',
            style: TextStyle(color: Color(0xFFE8D5FF))),
        content: const Text('¿Eliminar esta memoria?',
            style: TextStyle(color: Color(0xFFE8D5FF))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF7B61FF)))),
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

class _StarfieldPainter extends CustomPainter {
  final double progress;
  final List<_Star> stars;

  _StarfieldPainter(this.progress)
      : stars = List.generate(
          120,
          (i) {
            final rng = Random(i);
            return _Star(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              size: rng.nextDouble() * 2 + 0.5,
              opacity: rng.nextDouble() * 0.8 + 0.2,
              twinkleOffset: rng.nextDouble(),
            );
          },
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final twinkle =
          0.5 + 0.5 * sin((progress + star.twinkleOffset) * 2 * pi);
      paint.color = Colors.white.withOpacity(star.opacity * twinkle * 0.7);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) =>
      old.progress != progress;
}

class _NebulaePainter extends CustomPainter {
  final double progress;

  const _NebulaePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = 0.03 + 0.02 * sin(progress * 2 * pi);
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    paint.color = const Color(0xFF7B61FF).withOpacity(opacity * 2);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      180,
      paint,
    );

    paint.color = const Color(0xFF4B6BFF).withOpacity(opacity);
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.65),
      140,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NebulaePainter old) =>
      old.progress != progress;
}

class _Star {
  final double x, y, size, opacity, twinkleOffset;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleOffset,
  });
}