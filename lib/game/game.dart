import 'dart:ui';

import 'package:flame/game.dart';

import 'collision/utils.dart';
import 'config.dart';
import 'game_over/game_over.dart';
import 'horizon/horizon.dart';
import 'trex/config.dart';
import 'trex/trex.dart';

enum GameStatus { playing, waiting, gameOver }

class TRexJumper extends BaseGame {
	TRexJumper({Image spriteImage}) {
		character = TRex(spriteImage);
		horizon = Horizon(spriteImage);
		gameOverPanel = GameOverPanel(spriteImage);
		
		this..add(horizon)..add(character)..add(gameOverPanel);
	}
	
	TRex character;
	Horizon horizon;
	GameOverPanel gameOverPanel;
	GameStatus status = GameStatus.waiting;
	double currentSpeed = GameConfig.speed;
	double timePlaying = 0.0;
	
	bool get playing => status == GameStatus.playing;
	
	bool get gameOver => status == GameStatus.gameOver;
	
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
	}
	
	void startGame() {
		character.status = TRexStatus.running;
		status = GameStatus.playing;
		character.hasPlayedIntro = true;
	}
	
	void stop() {
		status = GameStatus.gameOver;
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
			} else {
				doGameOver();
			}
		}
	}
}
