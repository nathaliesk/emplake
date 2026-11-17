import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_controller.dart';

enum Sfx { tap, success, error, skip }

/// Efeitos sonoros sintetizados em memória (arquivos WAV gerados em Dart).
///
/// Assim o app não depende de arquivos de áudio em `assets/`. O som só toca
/// se o jogador ligar nas configurações: o padrão é **desligado**.
class SoundService {
  SoundService(this._enabled);

  final bool Function() _enabled;
  final AudioPlayer _player = AudioPlayer();
  final Map<Sfx, Uint8List> _cache = {};

  Future<void> play(Sfx sfx) async {
    if (!_enabled()) return;
    try {
      final bytes = _cache.putIfAbsent(sfx, () => _build(sfx));
      await _player.stop();
      await _player.play(BytesSource(bytes), volume: 0.5);
    } catch (e) {
      // Som é opcional: se o navegador bloquear, o jogo segue normalmente.
      debugPrint('Falha ao tocar som: $e');
    }
  }

  Uint8List _build(Sfx sfx) => switch (sfx) {
        Sfx.tap => _wav([(880, 0.05)]),
        Sfx.success => _wav([(523.25, 0.12), (659.25, 0.12), (783.99, 0.22)]),
        Sfx.error => _wav([(196, 0.18), (155.56, 0.25)]),
        Sfx.skip => _wav([(440, 0.08), (330, 0.12)]),
      };

  /// Gera um WAV PCM 16 bits mono com uma sequência de notas (frequência, segundos).
  static Uint8List _wav(List<(double, double)> notes) {
    const rate = 22050;
    final samples = <int>[];
    for (final (freq, seconds) in notes) {
      final n = (rate * seconds).round();
      for (var i = 0; i < n; i++) {
        final t = i / rate;
        // Envelope curto para não "estalar" no começo e no fim da nota.
        final env = math.min(1.0, math.min(i / 200, (n - i) / 400));
        final v = math.sin(2 * math.pi * freq * t) * env * 0.6;
        samples.add((v * 32767).round());
      }
    }
    final dataLen = samples.length * 2;
    final b = ByteData(44 + dataLen);
    void str(int o, String s) {
      for (var i = 0; i < s.length; i++) {
        b.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    b.setUint32(4, 36 + dataLen, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    b.setUint32(16, 16, Endian.little);
    b.setUint16(20, 1, Endian.little); // PCM
    b.setUint16(22, 1, Endian.little); // mono
    b.setUint32(24, rate, Endian.little);
    b.setUint32(28, rate * 2, Endian.little);
    b.setUint16(32, 2, Endian.little);
    b.setUint16(34, 16, Endian.little);
    str(36, 'data');
    b.setUint32(40, dataLen, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      b.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return b.buffer.asUint8List();
  }
}

final soundProvider = Provider<SoundService>((ref) {
  return SoundService(() => ref.read(settingsProvider).soundEnabled);
});
