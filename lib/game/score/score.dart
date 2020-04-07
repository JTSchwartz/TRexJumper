import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';

import 'config.dart';

class ScorePanel extends PositionComponent
    with Resizable, HasGameRef, Tapable, ComposedComponent {
	ScorePanel(Image spriteImage) : super() {
	}
}

class ScoreText extends SpriteComponent with Resizable {
  int digit;

  ScoreText(Image spriteImage, double xPosition, digit)
      : super.fromSprite(
          ScoreConfig.numWidth,
          ScoreConfig.numHeight,
          Sprite.fromImage(
            spriteImage,
            x: xPosition,
            y: 2.0,
            width: ScoreConfig.numWidth,
            height: ScoreConfig.numHeight,
          ),
        ) {
    this.digit = digit;
  }

  @override
  void resize(Size size) {
    if (width > size.width * 0.8) width = size.width * 0.8;
    y = size.height * 0.25;
    x = (size.width / 2) - width / 2;
  }
}
