import '../collision/box.dart';

abstract class ObstacleType {
  String type;
  double width;
  double height;
  double y;
  int multipleSpeed;
  double minGap;
  double minSpeed;
  int numFrames;
  double frameRate;
  double speedOffset;

  List<CollisionBox> collisionBoxes;
}
