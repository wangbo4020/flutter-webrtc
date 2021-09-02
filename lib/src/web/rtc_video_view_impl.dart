import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../interface/enums.dart';
import '../rtc_video_renderer.dart';
import '../web/rtc_video_renderer_impl.dart';

class RTCVideoView extends StatefulWidget {
  RTCVideoView(
    this._renderer, {
    Key? key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
    this.filterQuality = FilterQuality.low,
    this.videoBuilder,
  }) : super(key: key);

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final FilterQuality filterQuality;
  final VideoBuilder? videoBuilder;
  @override
  _RTCVideoViewState createState() => _RTCVideoViewState();
}

class _RTCVideoViewState extends State<RTCVideoView> {
  _RTCVideoViewState();

  RTCVideoRendererWeb get videoRenderer =>
      widget._renderer.delegate as RTCVideoRendererWeb;

  @override
  void initState() {
    super.initState();
    widget._renderer.delegate.addListener(_onRendererListener);
    videoRenderer.mirror = widget.mirror;
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  void _onRendererListener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget._renderer.delegate.removeListener(_onRendererListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(RTCVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    Timer(
        Duration(milliseconds: 10), () => videoRenderer.mirror = widget.mirror);
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  Widget buildVideoElementView() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(videoRenderer.mirror ? pi * -1 : 0),
      child: HtmlElementView(
          viewType: 'RTCVideoRenderer-${videoRenderer.textureId}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = constraints.maxWidth;
      final height = constraints.maxHeight;

      Widget child = widget._renderer.renderVideo
          ? buildVideoElementView()
          : Container();

      if (widget.videoBuilder != null) {
        child = widget.videoBuilder!(Size(width, height), child);
      }

      return Center(
          child: Container(
        width: width,
        height: height,
        child: child,
      ));
    });
  }
}

typedef VideoBuilder = Widget Function(Size size, Widget? child);