import 'dart:math';

class RandomUtils {
  static final _random = Random();

  static T choose<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  static int rnd(int min, int max, {Random rnd}) {
    return min + (rnd ?? _random).nextInt(max - min);
  }
}
