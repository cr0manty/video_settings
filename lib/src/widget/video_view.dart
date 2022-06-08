import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_settings/src/enum/renderer_enum.dart';
import 'package:video_settings/src/renderer/example_video_renderer.dart';

export 'package:video_settings/src/enum/renderer_enum.dart';

class VideoView extends StatefulWidget {
  final ExampleVideoRenderer _renderer;
  final VideoViewFit objectFit;
  final bool mirror;
  final FilterQuality filterQuality;

  const VideoView(
    this._renderer, {
    this.objectFit = VideoViewFit.contain,
    this.mirror = false,
    this.filterQuality = FilterQuality.low,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) => Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              fit: widget.objectFit == VideoViewFit.contain
                  ? BoxFit.contain
                  : BoxFit.cover,
              child: Center(
                child: SizedBox(
                  width: constraints.maxHeight,
                  height: constraints.maxHeight,
                  child: Builder(
                    builder: (context) {
                      if (widget._renderer.textureId == null) {
                        return const SizedBox.shrink();
                      }
                      return Transform(
                        transform: Matrix4.identity()
                          ..rotateY(widget.mirror ? -pi : 0.0),
                        alignment: FractionalOffset.center,
                        child: Texture(
                          textureId: widget._renderer.textureId!,
                          filterQuality: widget.filterQuality,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
