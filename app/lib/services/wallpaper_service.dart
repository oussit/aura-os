
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/wallpaper_model.dart';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('com.auraos/wallpaper');
  static const EventChannel _sensorChannel = EventChannel('com.auraos/sensors');
  static const EventChannel _batteryChannel = EventChannel('com.auraos/battery');
  static const EventChannel _musicChannel = EventChannel('com.auraos/music');

  /// Set live wallpaper from URL or local path
  Future<bool> setWallpaper({
    required String path,
    required WallpaperTarget target,
    List<AnimationEffect>? effects,
    WallpaperSettings? settings,
  }) async {
    try {
      final result = await _channel.invokeMethod('setWallpaper', {
        'path': path,
        'target': target.name,
        'effects': effects?.map((e) => e.toJson()).toList() ?? [],
        'settings': settings?.toJson() ?? {},
      });
      return result == true;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Set live wallpaper with full animation config
  Future<bool> setLiveWallpaper({
    required String imagePath,
    required List<AnimationEffect> effects,
    required WallpaperSettings settings,
  }) async {
    try {
      final result = await _channel.invokeMethod('setLiveWallpaper', {
        'imagePath': imagePath,
        'effects': effects.map((e) => e.toJson()).toList(),
        'settings': settings.toJson(),
        'fps': settings.targetFps,
        'batteryOptimized': settings.batteryOptimized,
      });
      return result == true;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Preview wallpaper before applying
  Future<bool> previewWallpaper({
    required String imagePath,
    required List<AnimationEffect> effects,
  }) async {
    try {
      final result = await _channel.invokeMethod('previewWallpaper', {
        'imagePath': imagePath,
        'effects': effects.map((e) => e.toJson()).toList(),
      });
      return result == true;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stream device sensor data for interactive wallpapers
  Stream<SensorData> get sensorStream {
    return _sensorChannel.receiveBroadcastStream().map((data) {
      return SensorData(
        accelerometerX: data['accelX'] ?? 0,
        accelerometerY: data['accelY'] ?? 0,
        accelerometerZ: data['accelZ'] ?? 0,
        gyroscopeX: data['gyroX'] ?? 0,
        gyroscopeY: data['gyroY'] ?? 0,
        gyroscopeZ: data['gyroZ'] ?? 0,
      );
    });
  }

  /// Stream battery state
  Stream<BatteryState> get batteryStream {
    return _batteryChannel.receiveBroadcastStream().map((data) {
      return BatteryState(
        level: data['level'] ?? 100,
        isCharging: data['isCharging'] ?? false,
        chargingType: data['chargingType'] ?? 'none',
      );
    });
  }

  /// Stream music playback state
  Stream<MusicState> get musicStream {
    return _musicChannel.receiveBroadcastStream().map((data) {
      return MusicState(
        isPlaying: data['isPlaying'] ?? false,
        title: data['title'] ?? '',
        artist: data['artist'] ?? '',
        bpm: data['bpm'] ?? 0,
      );
    });
  }

  /// Check if wallpaper is currently set
  Future<bool> isLiveWallpaperActive() async {
    try {
      return await _channel.invokeMethod('isActive') == true;
    } catch (_) {
      return false;
    }
  }

  /// Open Android live wallpaper picker
  Future<void> openWallpaperSettings() async {
    await _channel.invokeMethod('openSettings');
  }
}

enum WallpaperTarget { home, lock, both }

class SensorData {
  final double accelerometerX, accelerometerY, accelerometerZ;
  final double gyroscopeX, gyroscopeY, gyroscopeZ;

  SensorData({
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,
  });
}

class BatteryState {
  final int level;
  final bool isCharging;
  final String chargingType;

  BatteryState({required this.level, required this.isCharging, required this.chargingType});
}

class MusicState {
  final bool isPlaying;
  final String title;
  final String artist;
  final int bpm;

  MusicState({required this.isPlaying, required this.title, required this.artist, required this.bpm});
}
