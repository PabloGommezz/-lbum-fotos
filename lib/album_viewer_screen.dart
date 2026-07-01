// lib/screens/album_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:photo_album_app/album_model.dart';
import 'package:photo_album_app/album_provider.dart';
import 'package:photo_album_app/botanic_screen.dart';
import 'package:photo_album_app/cosmos_screen.dart';
import 'package:photo_album_app/noir_cinema_screen.dart';
import 'package:photo_album_app/polaroid_drift_screen.dart';
import 'package:photo_album_app/saukura_journal_screen.dart';
import 'package:provider/provider.dart';


class AlbumViewerScreen extends StatelessWidget {
  final Album album;

  const AlbumViewerScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlbumProvider>(
      builder: (context, provider, _) {
        // Always use fresh data from provider
        final freshAlbum = provider.getAlbum(album.id) ?? album;

        switch (freshAlbum.theme) {
          case AlbumTheme.botanica:
            return BotanicaScreen(album: freshAlbum);
          case AlbumTheme.polaroidDrift:
            return PolaroidDriftScreen(album: freshAlbum);
          case AlbumTheme.noirCinema:
            return NoirCinemaScreen(album: freshAlbum);
          case AlbumTheme.cosmos:
            return CosmosScreen(album: freshAlbum);
          case AlbumTheme.sakuraJournal:
            return SakuraJournalScreen(album: freshAlbum);
        }
      },
    );
  }
}