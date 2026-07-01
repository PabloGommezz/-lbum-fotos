// lib/widgets/photo_detail_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album_app/album_model.dart';
import 'package:photo_album_app/album_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
class PhotoDetailSheet extends StatefulWidget {
  final PhotoItem photo;
  final String albumId;
  final Color accentColor;
  final bool isDark;

  const PhotoDetailSheet({
    super.key,
    required this.photo,
    required this.albumId,
    required this.accentColor,
    this.isDark = false,
  });

  @override
  State<PhotoDetailSheet> createState() => _PhotoDetailSheetState();
}

class _PhotoDetailSheetState extends State<PhotoDetailSheet> {
  late TextEditingController _captionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _captionController =
        TextEditingController(text: widget.photo.caption ?? '');
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF111111) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF2A1F14);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Full-screen photo viewer
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildPhotoViewer(),
                ),
              ),

              // Caption & actions
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Caption editor
                    if (_isEditing)
                      TextField(
                        controller: _captionController,
                        autofocus: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Añade un pie de foto...',
                          hintStyle: TextStyle(
                              color: textColor.withOpacity(0.4)),
                          border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: widget.accentColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: widget.accentColor),
                          ),
                        ),
                        onSubmitted: (_) => _saveCaption(),
                      )
                    else if (widget.photo.caption != null &&
                        widget.photo.caption!.isNotEmpty)
                      Text(
                        widget.photo.caption!,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: textColor.withOpacity(0.8),
                          height: 1.5,
                        ),
                      )
                    else
                      Text(
                        'Sin pie de foto',
                        style: TextStyle(
                          color: textColor.withOpacity(0.3),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        _ActionButton(
                          icon: _isEditing
                              ? Icons.check
                              : Icons.edit_outlined,
                          label: _isEditing ? 'Guardar' : 'Editar texto',
                          color: widget.accentColor,
                          isDark: widget.isDark,
                          onTap: _isEditing
                              ? _saveCaption
                              : () =>
                                  setState(() => _isEditing = true),
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.fullscreen,
                          label: 'Pantalla completa',
                          color: widget.accentColor,
                          isDark: widget.isDark,
                          onTap: () =>
                              _openFullscreen(context),
                        ),
                        const Spacer(),
                        _ActionButton(
                          icon: Icons.delete_outline,
                          label: 'Eliminar',
                          color: Colors.red,
                          isDark: widget.isDark,
                          onTap: () => _deletePhoto(context),
                        ),
                      ],
                    ),

                    // Safe area bottom
                    SizedBox(
                        height:
                            MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoViewer() {
    if (widget.photo.path.startsWith('/')) {
      return PhotoView(
        imageProvider: FileImage(File(widget.photo.path)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    }
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white54, size: 64),
      ),
    );
  }

  void _saveCaption() {
    context.read<AlbumProvider>().updatePhotoCaption(
          widget.albumId,
          widget.photo.id,
          _captionController.text.trim(),
        );
    setState(() => _isEditing = false);
  }

  void _deletePhoto(BuildContext context) {
    Navigator.pop(context);
    context
        .read<AlbumProvider>()
        .removePhoto(widget.albumId, widget.photo.id);
  }

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoView(
                imageProvider: widget.photo.path.startsWith('/')
                    ? FileImage(File(widget.photo.path))
                        as ImageProvider
                    : const AssetImage('assets/placeholder.png'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF2A1F14).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}