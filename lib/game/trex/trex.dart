import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';

import 'config.dart';

enum TRexStatus { crashed, ducking, jumping, running, idle, intro }

class TRex extends PositionComponent
    with HasGameRef, Tapable, ComposedComponent, Resizable {
  bool isIdle = true;

  TRexStatus status = TRexStatus.idle;

  IdleTRex idleTRex;
  RunningTRex runningTRex;
  JumpingTRex jumpingTRex;
  CrashedTRex crashedTRex;
  DuckingTRex duckingTRex;

  double jumpVelocity = 0.0;
  bool reachedMinHeight = false;
  int jumpCount = 0;
  bool hasPlayedIntro = false;

  TRex(Image spriteImage)
      : runningTRex = RunningTRex(spriteImage),
        idleTRex = IdleTRex(spriteImage),
        jumpingTRex = JumpingTRex(spriteImage),
        crashedTRex = CrashedTRex(spriteImage),
        duckingTRex = DuckingTRex(spriteImage),
        super();

  PositionComponent get actualDino {
    switch (status) {
      case TRexStatus.crashed:
        return crashedTRex;
      case TRexStatus.idle:
        return idleTRex;
      case TRexStatus.jumping:
        return jumpingTRex;
      case TRexStatus.ducking:
        return duckingTRex;
      default:
        return runningTRex;
    }
  }

  double get groundYPosition {
    if (size == null) return 0.0;
    return (size.height / 2) - TRexConfig.height / 2;
  }

  double get groundYPositionDucking {
    if (size == null) return 0.0;
    return (size.height / 2);
  }

  bool get playingIntro => status == TRexStatus.intro;

  bool get ducking => status == TRexStatus.ducking;

  void jump(double speed) {
    if (status == TRexStatus.jumping || status == TRexStatus.ducking) return;
  
    status = TRexStatus.jumping;
    this.jumpVelocity = TRexConfig.initialJumpVelocity - (speed / 10);
    this.reachedMinHeight = false;
  }

  void duck() {
    if (status == TRexStatus.jumping) return;
    if (status == TRexStatus.ducking) return stand();
  
    status = TRexStatus.ducking;
  }
  
  void stand() {
    status = TRexStatus.running;
  }

  @override
  void render(Canvas c) {
    this.actualDino.render(c);
  }

  void reset() {
    y = groundYPosition;
    jumpVelocity = 0.0;
    jumpCount = 0;
    status = TRexStatus.running;
  }

  void update(double t) {
    if (status == TRexStatus.jumping) {
      y += jumpVelocity;
      this.jumpVelocity += TRexConfig.gravity;

      if (this.y > this.groundYPosition) {
        this.reset();
        this.jumpCount++;
      }
    } else if (status == TRexStatus.ducking) {
      y = this.groundYPositionDucking;
    } else {
      y = this.groundYPosition;
    }

    if (jumpCount == 1 && !playingIntro && !hasPlayedIntro) {
      status = TRexStatus.intro;
    } else if (playingIntro && x < TRexConfig.startXPosition) {
      x += ((TRexConfig.startXPosition / TRexConfig.introDuration) * t * 5000);
    }

    updateCoordinates(t);
  }

  void updateCoordinates(double t) {
    this.actualDino.x = x;
    this.actualDino.y = y;
    this.actualDino.update(t);
  }
}

class RunningTRex extends AnimationComponent {
  RunningTRex(Image spriteImage)
      : super(
            88.0,
            90.0,
            Animation.spriteList([
              Sprite.fromImage(
                spriteImage,
                width: TRexConfig.width,
                height: TRexConfig.height,
                x: 1514.0,
                y: 4.0,
              ),
              Sprite.fromImage(
                spriteImage,
                width: TRexConfig.width,
                height: TRexConfig.height,
                x: 1602.0,
                y: 4.0,
              ),
            ], stepTime: 0.2, loop: true));
}

class IdleTRex extends SpriteComponent {
  IdleTRex(Image spriteImage)
      : super.fromSprite(
            TRexConfig.width,
            TRexConfig.height,
            Sprite.fromImage(spriteImage,
                width: TRexConfig.width,
                height: TRexConfig.height,
                x: 76.0,
                y: 6.0));
}

class JumpingTRex extends SpriteComponent {
  JumpingTRex(Image spriteImage)
      : super.fromSprite(
            TRexConfig.width,
            TRexConfig.height,
            Sprite.fromImage(spriteImage,
                width: TRexConfig.width,
                height: TRexConfig.height,
                x: 1339.0,
                y: 6.0));
}

class CrashedTRex extends SpriteComponent {
  CrashedTRex(Image spriteImage)
      : super.fromSprite(
            TRexConfig.width,
            TRexConfig.height,
            Sprite.fromImage(spriteImage,
                width: TRexConfig.width,
                height: TRexConfig.height,
                x: 1782.0,
                y: 6.0));
}

class DuckingTRex extends AnimationComponent {
  DuckingTRex(Image spriteImage)
      : super(
            TRexConfig.widthDuck,
            TRexConfig.heightDuck,
            Animation.spriteList([
              Sprite.fromImage(spriteImage,
                  width: TRexConfig.widthDuck,
                  height: TRexConfig.heightDuck,
                  x: 1870.0,
                  y: 40.0),
              Sprite.fromImage(spriteImage,
                  width: TRexConfig.widthDuck,
                  height: TRexConfig.heightDuck,
                  x: 1988.0,
                  y: 40.0),
            ], stepTime: 0.2, loop: true));
}
