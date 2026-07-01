// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album_app/album_card.dart';
import 'package:photo_album_app/album_model.dart';
import 'package:photo_album_app/album_provider.dart';
import 'package:provider/provider.dart';

import 'create_album_screen.dart';
import 'album_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF8F4EE),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Mis Álbumes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A1F14),
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F4EE),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48, right: 24),
                    child: Text(
                      '📖',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Consumer<AlbumProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B4F3A),
                    ),
                  ),
                );
              }

              if (provider.albums.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = provider.albums[index];
                      return AlbumCard(
                        album: album,
                        onTap: () => _openAlbum(context, album),
                        onDelete: () => _deleteAlbum(context, album),
                      )
                          .animate(delay: Duration(milliseconds: index * 80))
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.15, end: 0);
                    },
                    childCount: provider.albums.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📷', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 20),
        Text(
          'Tus memorias te esperan',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            color: const Color(0xFF2A1F14),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea tu primer álbum y empieza\na coleccionar momentos únicos',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF2A1F14).withOpacity(0.5),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _createAlbum(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B4F3A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Crear primer álbum',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _createAlbum(context),
      backgroundColor: const Color(0xFF2A1F14),
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: Text(
        'Nuevo álbum',
        style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _createAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateAlbumScreen()),
    );
  }

  void _openAlbum(BuildContext context, Album album) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => AlbumViewerScreen(album: album),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _deleteAlbum(BuildContext context, Album album) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar álbum'),
        content: Text(
            '¿Eliminar "${album.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AlbumProvider>().deleteAlbum(album.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}