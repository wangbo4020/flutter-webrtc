import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_video_renderer_impl.dart';

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
  RTCVideoViewState createState() => RTCVideoViewState();
}

class RTCVideoViewState extends State<RTCVideoView> {
  RTCVideoViewState();

  RTCVideoRenderer get videoRenderer => widget._renderer;

  @override
  void initState() {
    super.initState();
    videoRenderer.addListener(_onRendererListener);
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
    if (mounted) {
      super.dispose();
    }
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