import 'dart:async';

import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:audioplayers/audioplayers.dart';

class Music {
  static AudioPlayer player = AudioPlayer();
  static AudioPlayer backgroundPlayer = AudioPlayer();
  static var _filename;
  static var _status;

  static get status => _status;

  static set status(status) {
    _status = status;
  }

  get filename => _filename;

  set filename(filename) {
    _filename = filename;
  }

  play(String file) async {
    bool ply = await (utils.getSfxValue());

    if (ply) {
      _filename = file;

      if (_filename == backMusic && backgroundPlayer.state != PlayerState.playing) {
        //player = await cache. loop(_filename);
        //   player = await cache.load(_filename);

        await backgroundPlayer.play(AssetSource("music/$_filename"));
        status = "playing";
      } else {
        await player.play(AssetSource("music/$_filename"));
        //await player?.play(AssetSource("music/$_filename"));
        print("now player is ${player.state}");
      }
    }
  }

  static pause() async {
    if (await (utils.getSfxValue() as FutureOr<bool>)) {
      status = "paused";
      player.pause();
      backgroundPlayer.pause();
    }
  }

  stop() async {
    print("status calling");
    status = "stopped";
    player.stop();
    backgroundPlayer.stop();
    print("status ${player.state}");
    print("status ${backgroundPlayer.state}");
  }
}
