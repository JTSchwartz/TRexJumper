import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';

import 'edge.dart';

class Horizon extends PositionComponent
    with Resizable, HasGameRef, Tapable, ComposedComponent {
  Horizon(Image spriteImage) {
    horizonEdge = HorizonEdge(spriteImage);
    add(horizonEdge);
  }

  HorizonEdge horizonEdge;

  @override
  void update(double t) {
    horizonEdge.y = y;
    super.update(t);
  }

  void updateWithSpeed(double t, double speed) {
    if (size == null) return;

    y = (size.height / 2) + 21.0;

    for (final c in components) {
      final positionComponent = c as PositionComponent;
      positionComponent.y = y;
    }

    horizonEdge.updateWithSpeed(t, speed);
    super.update(t);
  }

  void reset() {
    horizonEdge.reset();
  }
}
