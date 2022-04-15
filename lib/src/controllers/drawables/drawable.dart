import 'dart:ui';

/// Abstract class to define a drawable object.
abstract class Drawable {
  /// Whether the drawable is hidden or not.
  final bool hidden;

  final int id;

  /// Default constructor.
  const Drawable({this.hidden = false, this.id = 0});

  /// Draws the drawable on the provided [canvas] of size [size].
  void draw(Canvas canvas, Size size);

  bool get isHidden => hidden;

  bool get isNotHidden => !hidden;

  int get getid => id;

  /// Checks equality between two [Drawable]s.
  // @override
  // bool operator ==(Object other) {
  //   return other is Drawable && other.hidden == hidden;
  // }
  //
  // @override
  // int get hashCode {
  //   return hidden.hashCode;
  // }
}
