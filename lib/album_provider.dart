// lib/models/album_provider.dart

import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'album_model.dart';

class AlbumProvider extends ChangeNotifier {
  List<Album> _albums = [];
  bool _isLoading = false;

  List<Album> get albums => _albums;
  bool get isLoading => _isLoading;

  AlbumProvider() {
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('albums');
      if (data != null) {
        final List<dynamic> json = jsonDecode(data);
        _albums = json.map((j) => Album.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Error loading albums: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveAlbums() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'albums',
        jsonEncode(_albums.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving albums: $e');
    }
  }

  Future<Album> createAlbum({
    required String title,
    String? description,
    required AlbumTheme theme,
  }) async {
    final album = Album(
      title: title,
      description: description,
      theme: theme,
    );
    _albums.insert(0, album);
    await _saveAlbums();
    notifyListeners();
    return album;
  }

  Future<void> deleteAlbum(String albumId) async {
    _albums.removeWhere((a) => a.id == albumId);
    await _saveAlbums();
    notifyListeners();
  }

  Future<void> addPhotos(String albumId, List<String> paths) async {
    final idx = _albums.indexWhere((a) => a.id == albumId);
    if (idx == -1) return;

    final rng = Random();
    final newPhotos = paths.map((path) {
      double rotation = 0;
      Offset offset = Offset.zero;
      final theme = _albums[idx].theme;

      // Theme-specific randomization
      if (theme == AlbumTheme.polaroidDrift) {
        rotation = (rng.nextDouble() - 0.5) * 0.3; // ±8.6 degrees
        offset = Offset(
          (rng.nextDouble() - 0.5) * 20,
          (rng.nextDouble() - 0.5) * 20,
        );
      } else if (theme == AlbumTheme.botanica) {
        rotation = (rng.nextDouble() - 0.5) * 0.1; // subtle
      }

      return PhotoItem(path: path, rotation: rotation, offset: offset);
    }).toList();

    _albums[idx].photos.addAll(newPhotos);
    await _saveAlbums();
    notifyListeners();
  }

  Future<void> removePhoto(String albumId, String photoId) async {
    final idx = _albums.indexWhere((a) => a.id == albumId);
    if (idx == -1) return;
    _albums[idx].photos.removeWhere((p) => p.id == photoId);
    await _saveAlbums();
    notifyListeners();
  }

  Future<void> updatePhotoCaption(
      String albumId, String photoId, String caption) async {
    final albumIdx = _albums.indexWhere((a) => a.id == albumId);
    if (albumIdx == -1) return;
    final photoIdx =
        _albums[albumIdx].photos.indexWhere((p) => p.id == photoId);
    if (photoIdx == -1) return;
    _albums[albumIdx].photos[photoIdx] =
        _albums[albumIdx].photos[photoIdx].copyWith(caption: caption);
    await _saveAlbums();
    notifyListeners();
  }

  Album? getAlbum(String albumId) {
    try {
      return _albums.firstWhere((a) => a.id == albumId);
    } catch (_) {
      return null;
    }
  }
}