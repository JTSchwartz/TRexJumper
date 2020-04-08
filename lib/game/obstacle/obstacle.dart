import 'dart:collection';
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';

import '../collision/box.dart';
import '../config.dart';
import '../horizon/config.dart';
import '../utils.dart';
import 'config.dart';
import 'obstacle_type.dart';

class ObstacleManager extends PositionComponent
    with HasGameRef, Tapable, ComposedComponent, Resizable {
  ObstacleManager(this.spriteImage) : super();
  ListQueue<String> history = ListQueue();
  Image spriteImage;
  double horizonY = 0.0;

  void setHorizonY(yPosition) {
    horizonY = yPosition;
  }

  void updateWithSpeed(double t, double speed) {
    for (final o in components) {
      final obstacle = o as Obstacle;
      obstacle.updateWithSpeed(t, speed);
    }

    if (components.isNotEmpty) {
      final lastObstacle = components.last as Obstacle;
      if (lastObstacle != null &&
          !lastObstacle.followingObstacleCreated &&
          lastObstacle.isVisible &&
          (lastObstacle.x + lastObstacle.width + lastObstacle.gap) <
              HorizonDimensions.width) {
        addNewObstacle(speed);
        lastObstacle.followingObstacleCreated = true;
      }
    } else
      addNewObstacle(speed);
  }

  void addNewObstacle(double speed) {
    final listOfObstacles = ["cactusSmall", "cactusLarge", "pterodactyl"];
    String newObstacleType =
        listOfObstacles[rand.nextInt(listOfObstacles.length)];

    if (duplicateObstacleCheck(newObstacleType)) {
      return;
    } else {
      final obstacle = Obstacle(spriteImage, newObstacleType, horizonY);

      obstacle.x = HorizonDimensions.width;

      components.add(obstacle);

      history.addFirst(newObstacleType);
      if (history.length > 1) {
        final sublist =
            history.toList().sublist(0, GameConfig.maxObstacleDuplication);
        history = ListQueue.from(sublist);
      }
    }
  }

  bool duplicateObstacleCheck(String nextType) {
    int duplicateCount = 0;
    for (final c in history) duplicateCount += c == nextType ? 1 : 0;
    return duplicateCount >= GameConfig.maxObstacleDuplication;
  }

  void reset() {
    components.clear();
    history.clear();
  }
}

class Obstacle extends PositionComponent
    with HasGameRef, Tapable, ComposedComponent, Resizable {
  bool toRemove = false;
  double jumpVelocity = 0.0;
  bool reachedMinHeight = false;
  int jumpCount = 0;
  bool hasPlayedIntro = false;
  bool followingObstacleCreated = false;
  double gap = ObstacleConfig.minGap;
  double y;
  double width;
  double height;
  int internalSize = 1;
  PositionComponent actualObstacle;
  List<CollisionBox> collisionBoxes;

  bool get isVisible => x + width > 0;

  Obstacle(Image spriteImage, String type, double horizonY) : super() {
    switch (type) {
      case "cactusSmall":
        actualObstacle = CactusSmall(spriteImage);
        collisionBoxes = ObstacleCollisionBox.smallCactus;
        break;
      case "cactusLarge":
        actualObstacle = CactusLarge(spriteImage);
        collisionBoxes = ObstacleCollisionBox.largeCactus;
        break;
      case "pterodactyl":
        actualObstacle = Pterodactyl(spriteImage);
        collisionBoxes = ObstacleCollisionBox.pterodactyl;
        break;
    }
    width = actualObstacle.width;
    height = actualObstacle.height;
    actualObstacle.y += horizonY;
    y = actualObstacle.y;
  }

  double getGap(double gapCoefficient, double speed) {
    final minGap =
        (width * speed * ObstacleConfig.minGapCoefficient * gapCoefficient)
                .round() /
            1;
    final maxGap = (minGap * ObstacleConfig.maxGapCoefficient).round() / 1;
    return randomDoubleInRange(minGap, maxGap);
  }

  @override
  void render(Canvas c) {
    this.actualObstacle.render(c);
  }

  @override
  bool destroy() {
    return toRemove;
  }

  @override
  void update(double t) {
    updateCoordinates(t);
  }

  void updateWithSpeed(double t, double speed) {
    if (toRemove) return;
    x -= speed * 50 * t;

    if (!isVisible) toRemove = true;
  }

  void updateCoordinates(double t) {
    this.actualObstacle.x = x;
    this.actualObstacle.update(t);
  }
}

class CactusSmall extends SpriteComponent with ObstacleType {
  String type = "cactusSmall";
  double width = 34.0;
  double height = 70.0;
  double y = -60.0;
  int multipleSpeed = 4;
  double minSpeed = 0.0;

  CactusSmall(Image spriteImage)
      : super.fromSprite(
            ObstacleConfig.smallCactusWidth,
            ObstacleConfig.smallCactusHeight,
            Sprite.fromImage(
              spriteImage,
              x: 446.0,
              y: 2.0,
              width: ObstacleConfig.smallCactusWidth,
              height: ObstacleConfig.smallCactusHeight,
            ));
}

class CactusLarge extends SpriteComponent with ObstacleType {
  String type = "cactusLarge";
  double width = 50.0;
  double height = 100.0;
  double y = -75.0;
  int multipleSpeed = 7;
  double minSpeed = 0.0;

  CactusLarge(Image spriteImage)
      : super.fromSprite(
            ObstacleConfig.largeCactusWidth,
            ObstacleConfig.largeCactusHeight,
            Sprite.fromImage(spriteImage,
                x: 652.0,
                y: 2.0,
                width: ObstacleConfig.largeCactusWidth,
                height: ObstacleConfig.largeCactusHeight));
}

class Pterodactyl extends AnimationComponent with ObstacleType {
  String type = "pterodactyl";
  double width = 84.0;
  double height = 60.0;
  double y = -110.0;
  int multipleSpeed = 7;
  double minSpeed = 0.0;

  Pterodactyl(Image spriteImage)
      : super(
            ObstacleConfig.pterodactylWidth,
            ObstacleConfig.pterodactylHeight,
            Animation.spriteList([
              Sprite.fromImage(
                spriteImage,
                width: ObstacleConfig.pterodactylWidth,
                height: ObstacleConfig.pterodactylHeight,
                x: 264.0,
                y: 6.0,
              ),
              Sprite.fromImage(
                spriteImage,
                width: ObstacleConfig.pterodactylWidth,
                height: ObstacleConfig.pterodactylHeight,
                x: 356.0,
                y: 6.0,
              ),
            ], stepTime: 0.4, loop: true));
}
