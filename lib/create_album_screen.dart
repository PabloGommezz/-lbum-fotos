// lib/screens/create_album_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album_app/album_model.dart';
import 'package:photo_album_app/album_provider.dart';
import 'package:provider/provider.dart';
import 'album_viewer_screen.dart';

class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  AlbumTheme _selectedTheme = AlbumTheme.botanica;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2A1F14)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nuevo Álbum',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF2A1F14),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            Text(
              'Título del álbum',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B4F3A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                color: const Color(0xFF2A1F14),
              ),
              decoration: InputDecoration(
                hintText: 'Ej: Viaje a Japón 2024',
                hintStyle: TextStyle(
                    color: const Color(0xFF2A1F14).withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Descripción (opcional)',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B4F3A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(color: Color(0xFF2A1F14)),
              decoration: InputDecoration(
                hintText: 'Una frase sobre este álbum...',
                hintStyle: TextStyle(
                    color: const Color(0xFF2A1F14).withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Elige una temática',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2A1F14),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cada temática tiene un diseño y estilo únicos',
              style: TextStyle(
                color: const Color(0xFF2A1F14).withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Theme cards
            ...albumThemes.asMap().entries.map((entry) {
              final themeData = entry.value;
              final isSelected = _selectedTheme == themeData.theme;
              return _ThemeCard(
                themeData: themeData,
                isSelected: isSelected,
                onTap: () =>
                    setState(() => _selectedTheme = themeData.theme),
              )
                  .animate(delay: Duration(milliseconds: entry.key * 80))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0);
            }),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createAlbum,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A1F14),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Crear álbum',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _createAlbum() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor añade un título al álbum')),
      );
      return;
    }

    setState(() => _isCreating = true);
    final album = await context.read<AlbumProvider>().createAlbum(
          title: title,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          theme: _selectedTheme,
        );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AlbumViewerScreen(album: album)),
      );
    }
  }
}

class _ThemeCard extends StatelessWidget {
  final AlbumThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.themeData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? themeData.primaryColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? themeData.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeData.primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Preview
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: themeData.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeData.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    themeData.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeData.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A1F14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeData.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2A1F14).withOpacity(0.55),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? themeData.primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? themeData.primaryColor
                        : const Color(0xFFCCC5BB),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}