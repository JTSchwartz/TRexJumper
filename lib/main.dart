import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/game.dart';

void main() async {
  Flame.audio.disableLog();

  runApp(Title(
    title: 'T-Rex Jumper',
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(color: Colors.white),
      child: GameWrapper(),
    ),
  ));

  SystemChrome.setEnabledSystemUIOverlays([]);
}

class GameWrapper extends StatefulWidget {
  @override
  _GameWrapperState createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  List<ui.Image> image;
  TRexJumper game;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() async {
    image = await Flame.images.loadAll(["sprite.png"]);
    game = TRexJumper(spriteImage: image[0]);
    setState(() {});
    Flame.util.addGestureRecognizer(TapGestureRecognizer()
      ..onTapDown = (TapDownDetails event) => game.onTap());
    Flame.util.addGestureRecognizer(DoubleTapGestureRecognizer()..onDoubleTap = () => game.onDoubleTap());

  }

  @override
  Widget build(BuildContext context) {
    if (image == null || game == null) return Container();
    return game.widget;
  }
}
