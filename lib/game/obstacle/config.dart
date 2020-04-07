import '../collision/box.dart';

class ObstacleConfig {
  static int maxObstacleLength = 3;
  static double minGap = 600.0;
  static double minGapCoefficient = 120.0;
  static double maxGapCoefficient = 1.5;
  static double smallCactusWidth = 34.0;
  static double smallCactusHeight = 70.0;
  static double largeCactusWidth = 50.0;
  static double largeCactusHeight = 100.0;
  static double pterodactylWidth = 84.0;
  static double pterodactylHeight = 72.0;
}

class ObstacleCollisionBox {
  static final List<CollisionBox> smallCactus = <CollisionBox>[
    CollisionBox(x: 5.0, y: 7.0, width: 10.0, height: 54.0),
    CollisionBox(x: 9.0, y: 0.0, width: 12.0, height: 68.0),
    CollisionBox(x: 15.0, y: 4.0, width: 14.0, height: 28.0)
  ];

  static final List<CollisionBox> largeCactus = <CollisionBox>[
    CollisionBox(x: 0.0, y: 12.0, width: 14.0, height: 76.0),
    CollisionBox(x: 8.0, y: 0.0, width: 14.0, height: 98.0),
    CollisionBox(x: 13.0, y: 10.0, width: 20.0, height: 76.0)
  ];

  static final List<CollisionBox> pterodactyl = <CollisionBox>[
    CollisionBox(x: 0.0, y: 0.0, width: 84.0, height: 60.0),
  ];
}
