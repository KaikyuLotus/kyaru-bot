import 'dart:math';

final _random = Random();

T choose<T>(List<T> list) => list[_random.nextInt(list.length)];

int rnd(int min, int max, {Random? rnd}) =>
    min + (rnd ?? _random).nextInt(max - min);

T? callIfNotNull<T, R>(T Function(R) foo, dynamic? parameter) {
  return parameter != null ? foo(parameter) : null;
}
