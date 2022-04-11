import '../../controllers/drawables/drawable.dart';

import '../drawables/object_drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when the selected [ObjectDrawable] of ObjectWidget changes.
///
/// Note that [drawable] will only be valid until the drawable is modified (moved, scaled, rotated, etc...),
/// so use this callback as a reference that the selected object drawable changed internally and nothing
/// more to avoid issues.
///
/// Use [PainterController.tapObjectDrawable] if you want to do any operations on the selected object drawable.

/// A notification that is dispatched when a drawable is deleted internally in Flutter Painter.
class DrawableTapNotification extends DrawableNotification<Drawable> {
  /// Creates a [DrawableTapNotification] with the given [drawable].
  DrawableTapNotification(drawable) : super(drawable);
}
