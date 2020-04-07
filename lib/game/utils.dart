import 'dart:math';

Random rand = Random();

double randomDoubleInRange(double min, double max) =>
    (rand.nextDouble() * (max - min) + min);
