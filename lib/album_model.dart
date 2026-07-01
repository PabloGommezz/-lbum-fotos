// lib/models/album_model.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum AlbumTheme {
  botanica,
  polaroidDrift,
  noirCinema,
  cosmos,
  sakuraJournal,
}

class PhotoItem {
  final String id;
  final String path; // local file path or asset path
  final String? caption;
  final DateTime addedAt;
  final double rotation; // slight random rotation for some themes
  final Offset offset; // slight offset for layouts

  PhotoItem({
    String? id,
    required this.path,
    this.caption,
    DateTime? addedAt,
    double? rotation,
    Offset? offset,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now(),
        rotation = rotation ?? 0.0,
        offset = offset ?? Offset.zero;

  PhotoItem copyWith({String? caption}) {
    return PhotoItem(
      id: id,
      path: path,
      caption: caption ?? this.caption,
      addedAt: addedAt,
      rotation: rotation,
      offset: offset,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'caption': caption,
        'addedAt': addedAt.toIso8601String(),
        'rotation': rotation,
        'offsetDx': offset.dx,
        'offsetDy': offset.dy,
      };

  factory PhotoItem.fromJson(Map<String, dynamic> json) => PhotoItem(
        id: json['id'],
        path: json['path'],
        caption: json['caption'],
        addedAt: DateTime.parse(json['addedAt']),
        rotation: json['rotation']?.toDouble() ?? 0.0,
        offset: Offset(
          json['offsetDx']?.toDouble() ?? 0.0,
          json['offsetDy']?.toDouble() ?? 0.0,
        ),
      );
}

class Album {
  final String id;
  String title;
  String? description;
  final AlbumTheme theme;
  final List<PhotoItem> photos;
  final DateTime createdAt;
  String? coverPhotoId;

  Album({
    String? id,
    required this.title,
    this.description,
    required this.theme,
    List<PhotoItem>? photos,
    DateTime? createdAt,
    this.coverPhotoId,
  })  : id = id ?? const Uuid().v4(),
        photos = photos ?? [],
        createdAt = createdAt ?? DateTime.now();

  PhotoItem? get coverPhoto {
    if (coverPhotoId != null) {
      try {
        return photos.firstWhere((p) => p.id == coverPhotoId);
      } catch (_) {}
    }
    return photos.isNotEmpty ? photos.first : null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'theme': theme.index,
        'photos': photos.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'coverPhotoId': coverPhotoId,
      };

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        theme: AlbumTheme.values[json['theme'] ?? 0],
        photos: (json['photos'] as List? ?? [])
            .map((p) => PhotoItem.fromJson(p))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        coverPhotoId: json['coverPhotoId'],
      );
}

// Theme metadata
class AlbumThemeData {
  final AlbumTheme theme;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String fontFamily;
  final String emoji;

  const AlbumThemeData({
    required this.theme,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.fontFamily,
    required this.emoji,
  });
}

const List<AlbumThemeData> albumThemes = [
  AlbumThemeData(
    theme: AlbumTheme.botanica,
    name: 'Botanica',
    description: 'Organic & earthy, like pressed flowers in a vintage journal',
    primaryColor: Color(0xFF4A5E3A),
    accentColor: Color(0xFFB8860B),
    backgroundColor: Color(0xFFF5EDD6),
    fontFamily: 'Playfair Display',
    emoji: '🌿',
  ),
  AlbumThemeData(
    theme: AlbumTheme.polaroidDrift,
    name: 'Polaroid Drift',
    description: 'Instant film nostalgia, scattered and carefree',
    primaryColor: Color(0xFF2C2C2C),
    accentColor: Color(0xFFFF6B35),
    backgroundColor: Color(0xFFFAF7F2),
    fontFamily: 'Special Elite',
    emoji: '📸',
  ),
  AlbumThemeData(
    theme: AlbumTheme.noirCinema,
    name: 'Noir Cinema',
    description: 'Cinematic & dramatic, like frames from a noir film',
    primaryColor: Color(0xFFE8E0D0),
    accentColor: Color(0xFFD4AF37),
    backgroundColor: Color(0xFF0D0D0D),
    fontFamily: 'Bebas Neue',
    emoji: '🎬',
  ),
  AlbumThemeData(
    theme: AlbumTheme.cosmos,
    name: 'Cosmos',
    description: 'Ethereal & vast, your memories float among the stars',
    primaryColor: Color(0xFFE8D5FF),
    accentColor: Color(0xFF7B61FF),
    backgroundColor: Color(0xFF050714),
    fontFamily: 'Orbitron',
    emoji: '✨',
  ),
  AlbumThemeData(
    theme: AlbumTheme.sakuraJournal,
    name: 'Sakura Journal',
    description: 'Delicate & minimalist, Japanese watercolor poetry',
    primaryColor: Color(0xFF3D3535),
    accentColor: Color(0xFFE8A0A8),
    backgroundColor: Color(0xFFFDF8F8),
    fontFamily: 'Noto Serif',
    emoji: '🌸',
  ),
];