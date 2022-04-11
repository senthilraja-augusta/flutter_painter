import '../drawables/drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when a drawable is updated internally in Flutter Painter.
class DrawableUpdatedNotification extends DrawableNotification<Drawable> {
  /// Creates a [DrawableUpdatedNotification] with the given [drawable].
  DrawableUpdatedNotification(drawable) : super(drawable);
}
