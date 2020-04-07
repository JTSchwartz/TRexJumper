import 'package:trexjumper/game/trex/trex.dart';

import '../obstacle/obstacle.dart';
import '../trex/config.dart';
import 'box.dart';

bool checkForCollision(Obstacle obstacle, TRex character) {
  final tRexBox = CollisionBox(
    x: character.x + 1,
    y: character.y + 1,
    width: TRexConfig.width - 2,
    height: TRexConfig.height - 2,
  );

  final obstacleBox = CollisionBox(
    x: obstacle.x + 1,
    y: obstacle.y + 1,
    width: obstacle.width,
    height: obstacle.height,
  );

  if (boxCompare(tRexBox, obstacleBox)) {
    final collisionBoxes = obstacle.collisionBoxes;
    final tRexCollisionBoxes =
        character.ducking ? TRexCollisionBox.ducking : TRexCollisionBox.running;

    bool crashed = false;

    collisionBoxes.forEach((obstacleCollisionBox) {
      final adjObstacleBox =
          createAdjustedCollisionBox(obstacleCollisionBox, obstacleBox);

      tRexCollisionBoxes.forEach((tRexCollisionBox) {
        final adjTRexBox =
            createAdjustedCollisionBox(tRexCollisionBox, tRexBox);
        crashed = crashed || boxCompare(adjTRexBox, adjObstacleBox);
      });
    });
    return crashed;
  }
  return false;
}

bool boxCompare(CollisionBox characterBox, CollisionBox obstacleBox) {
  final double obstacleX = obstacleBox.x;
  final double obstacleY = obstacleBox.y;

  return characterBox.x < obstacleX + obstacleBox.width &&
      characterBox.x + characterBox.width > obstacleX &&
      characterBox.y < obstacleBox.y + obstacleBox.height &&
      characterBox.height + characterBox.y > obstacleY;
}

CollisionBox createAdjustedCollisionBox(
    CollisionBox box, CollisionBox adjustment) {
  return CollisionBox(
    x: box.x + adjustment.x,
    y: box.y + adjustment.y,
    width: box.width,
    height: box.height,
  );
}
