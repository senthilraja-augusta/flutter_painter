import 'dart:async';
import 'dart:math';
import 'dart:ui';

import '../../controllers/events/add_text_painter_event.dart';
import '../../controllers/events/painter_event.dart';
import '../../controllers/settings/object_settings.dart';
import '../../controllers/settings/painter_settings.dart';
import '../../controllers/settings/shape_settings.dart';
import '../../controllers/settings/text_settings.dart';
import '../../controllers/settings/haptic_feedback_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../controllers/events/selected_object_drawable_removed_event.dart';
import '../../controllers/helpers/renderer_check/renderer_check.dart';
import '../../controllers/drawables/drawables.dart';
import '../../controllers/notifications/notifications.dart';
import '../../controllers/drawables/sized1ddrawable.dart';
import '../painters/painter.dart';
import '../../controllers/painter_controller.dart';
import '../../controllers/helpers/border_box_shadow.dart';
import '../../extensions/painter_controller_helper_extension.dart';
import 'painter_controller_widget.dart';
import 'dart:math' as math;

part 'free_style_widget.dart';
part 'object_widget.dart';
part 'text_widget.dart';
part 'shape_widget.dart';

typedef DrawableCreatedCallback = Function(Drawable drawable);

typedef DrawableUpdatedCallback = Function(Drawable drawable);

typedef DrawableDeletedCallback = Function(Drawable drawable);

typedef DrawableTappedCallback = Function(Drawable drawable);

/// Defines the builder used with [FlutterPainter.builder] constructor.
typedef FlutterPainterBuilderCallback = Widget Function(
    BuildContext context, Widget painter);

/// Widget that allows user to draw on it
class FlutterPainter extends StatelessWidget {
  /// The controller for this painter.
  final PainterController controller;

  final double width;

  final double height;

  /// Callback when a [Drawable] is created internally in [FlutterPainter].
  final DrawableCreatedCallback? onDrawableCreated;

  /// Callback when a [Drawable] is updated internally in [FlutterPainter].
  final DrawableDeletedCallback? onDrawableUpdated;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableDeletedCallback? onDrawableDeleted;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableTappedCallback? onDrawableTapped;

  /// Callback when the selected [ObjectDrawable] changes.
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;

  /// Callback when the [PainterSettings] of [PainterController] are updated internally.
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;

  /// The builder used to build this widget.
  ///
  /// Using the default constructor, it will default to returning the [_FlutterPainterWidget].
  ///
  /// Using the [FlutterPainter.builder] constructor, the user can define their own builder and build their own
  /// UI around [_FlutterPainterWidget], which gets re-built automatically when necessary.
  final FlutterPainterBuilderCallback _builder;

  /// Creates a [FlutterPainter] with the given [controller] and optional callbacks.
  const FlutterPainter(
      {Key? key,
      required this.controller,
      required this.width,
      required this.height,
      this.onDrawableCreated,
      this.onDrawableUpdated,
      this.onDrawableDeleted,
      this.onDrawableTapped,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : _builder = _defaultBuilder,
        super(key: key);

  /// Creates a [FlutterPainter] with the given [controller], [builder] and optional callbacks.
  ///
  /// Using this constructor, the [builder] will be called any time the [controller] updates.
  /// It is useful if you want to build UI that automatically rebuilds on updates from [controller].
  const FlutterPainter.builder(
      {Key? key,
      required this.controller,
      required this.width,
      required this.height,
      required FlutterPainterBuilderCallback builder,
      this.onDrawableCreated,
      this.onDrawableUpdated,
      this.onDrawableDeleted,
      this.onDrawableTapped,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : _builder = builder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PainterControllerWidget(
      controller: controller,
      child: ValueListenableBuilder<PainterControllerValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return _builder(
                context,
                _FlutterPainterWidget(
                  key: controller.painterKey,
                  width: width,
                  height: height,
                  controller: controller,
                  onDrawableCreated: onDrawableCreated,
                  onDrawableUpdated: onDrawableUpdated,
                  onDrawableDeleted: onDrawableDeleted,
                  onDrawableTapped: onDrawableTapped,
                  onPainterSettingsChanged: onPainterSettingsChanged,
                  onSelectedObjectDrawableChanged:
                      onSelectedObjectDrawableChanged,
                ));
          }),
    );
  }

  /// The default builder that is used when the default [FlutterPainter] constructor is used.
  static Widget _defaultBuilder(BuildContext context, Widget painter) {
    return painter;
  }
}

/// The actual widget that displays and allows control for all drawables.
class _FlutterPainterWidget extends StatelessWidget {
  /// The controller for this painter.
  final PainterController controller;

  final double width;

  final double height;

  /// Callback when a [Drawable] is created internally in [FlutterPainter].
  final DrawableCreatedCallback? onDrawableCreated;

  /// Callback when a [Drawable] is created internally in [FlutterPainter].
  final DrawableUpdatedCallback? onDrawableUpdated;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableDeletedCallback? onDrawableDeleted;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableTappedCallback? onDrawableTapped;

  /// Callback when the selected [ObjectDrawable] changes.
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;

  /// Callback when the [PainterSettings] of [PainterController] are updated internally.
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;

  /// Creates a [_FlutterPainterWidget] with the given [controller] and optional callbacks.
  const _FlutterPainterWidget(
      {Key? key,
      required this.controller,
      required this.width,
      required this.height,
      this.onDrawableCreated,
      this.onDrawableUpdated,
      this.onDrawableDeleted,
      this.onDrawableTapped,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
        onGenerateRoute: (settings) => PageRouteBuilder(
            settings: settings,
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              final controller = PainterController.of(context);
              return NotificationListener<FlutterPainterNotification>(
                onNotification: onNotification,
                child: InteractiveViewer(
                  constrained: false,
                  transformationController: controller.transformationController,
                  minScale: controller.settings.scale.enabled
                      ? controller.settings.scale.minScale
                      : 0.1,
                  maxScale: controller.settings.scale.enabled
                      ? controller.settings.scale.maxScale
                      : 1,
                  panEnabled: controller.settings.scale.enabled &&
                      (controller.freeStyleSettings.mode == FreeStyleMode.none),
                  scaleEnabled: controller.settings.scale.enabled,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: _FreeStyleWidget(
                      // controller: controller,
                      child: _ShapeWidget(
                        // controller: controller,
                        child: _ObjectWidget(
                          // controller: controller,
                          interactionEnabled: true,
                          child: CustomPaint(
                            painter: Painter(
                              drawables: controller.value.drawables,
                              background: controller.value.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  /// Handles all notifications that might be dispatched from children.
  bool onNotification(FlutterPainterNotification notification) {
    if (notification is DrawableCreatedNotification) {
      onDrawableCreated?.call(notification.drawable);
    } else if (notification is DrawableUpdatedNotification) {
      onDrawableUpdated?.call(notification.drawable);
    } else if (notification is DrawableDeletedNotification) {
      onDrawableDeleted?.call(notification.drawable);
    } else if (notification is DrawableTapNotification) {
      onDrawableTapped?.call(notification.drawable);
    } else if (notification is SelectedObjectDrawableUpdatedNotification) {
      onSelectedObjectDrawableChanged?.call(notification.drawable);
    } else if (notification is SettingsUpdatedNotification) {
      onPainterSettingsChanged?.call(notification.settings);
    }
    return true;
  }
}
