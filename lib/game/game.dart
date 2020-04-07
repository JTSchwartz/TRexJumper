import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/text_config.dart';
import 'package:trexjumper/game/obstacle/obstacle.dart';

import 'collision/utils.dart';
import 'config.dart';
import 'game_over/game_over.dart';
import 'horizon/horizon.dart';
import 'trex/config.dart';
import 'trex/trex.dart';

enum GameStatus { playing, waiting, gameOver }

class TRexJumper extends BaseGame {
  TRexJumper(Size screenSize, {Image spriteImage}) {
    character = TRex(spriteImage);
    horizon = Horizon(spriteImage);
    gameOverPanel = GameOverPanel(spriteImage);
    scoreText = TextComponent(scoreString, config: TextConfig(fontSize: 22.0));
    instructionsText =
        TextComponent(instructionsString, config: TextConfig(fontSize: 18.0));

    this..add(horizon)..add(character)..add(gameOverPanel);
    this
      ..add(instructionsText
        ..anchor = Anchor.bottomLeft
        ..x = 15
        ..y = screenSize.height - 10);
    this
      ..add(scoreText
        ..anchor = Anchor.topRight
        ..x = screenSize.width - 15
        ..y = 10);
  }

  TRex character;
  Horizon horizon;
  GameOverPanel gameOverPanel;
  GameStatus status = GameStatus.waiting;
  double currentSpeed = GameConfig.speed;
  double timePlaying = 0.0;
  int score = 0;
  Obstacle lastObstacle;
  String instructionsString =
      "Single Tap to Jump\nDouble Tap to Toggle Ducking";
  TextComponent instructionsText;
  TextComponent scoreText;

  bool get playing => status == GameStatus.playing;

  bool get gameOver => status == GameStatus.gameOver;

  String get scoreString => "Score: ${this.score}";

  void doGameOver() {
    gameOverPanel.visible = true;
    stop();
    character.status = TRexStatus.crashed;
  }

  void restart() {
    status = GameStatus.playing;
    character.reset();
    horizon.reset();
    currentSpeed = GameConfig.speed;
    gameOverPanel.visible = false;
    timePlaying = 0.0;
    score = 0;
    scoreText.text = scoreString;
    instructionsText.text = "";
  }

  void startGame() {
    character.status = TRexStatus.running;
    status = GameStatus.playing;
    character.hasPlayedIntro = true;
    instructionsText.text = "";
  }

  void stop() {
    status = GameStatus.gameOver;
    instructionsText.text = instructionsString;
  }

  bool passedObstacle(firstObstacle) {
    Obstacle obs = firstObstacle as Obstacle;
    return this.character.x > (obs.x + obs.width);
  }

  void onTap() {
    if (gameOver) {
      restart();
      return;
    }
    character.jump(currentSpeed);
  }

  void onDoubleTap() {
    character.duck();
  }

  @override
  void update(double t) {
    character.update(t);
    horizon.updateWithSpeed(0.0, currentSpeed);

    if (gameOver) {
      return;
    }

    if (character.playingIntro && character.x >= TRexConfig.startXPosition) {
      startGame();
    } else if (character.playingIntro) {
      horizon.updateWithSpeed(0.0, currentSpeed);
    }

    if (playing) {
      timePlaying += t;
      horizon.updateWithSpeed(t, currentSpeed);

      final obstacles = horizon.horizonEdge.obstacleManager.components;
      final hasCollision =
          obstacles.isNotEmpty && checkForCollision(obstacles.first, character);
      if (!hasCollision) {
        if (currentSpeed < GameConfig.maxSpeed) {
          currentSpeed += GameConfig.acceleration;
        }

        if (obstacles.isNotEmpty &&
            lastObstacle != obstacles.first &&
            passedObstacle(obstacles.first)) {
          lastObstacle = obstacles.first;
          ++score;
          scoreText.text = scoreString;
        }
      } else {
        doGameOver();
      }
    }
  }
}
