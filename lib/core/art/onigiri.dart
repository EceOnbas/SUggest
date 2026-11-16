import 'package:flutter/material.dart';

/// The poses of Onigiri, the SUggest mascot.
enum OnigiriPose {
  /// One arm waving: check your inbox, profile intro.
  hello,

  /// Holding a broom: empty and cleaned-up states.
  sweep,

  /// Both arms up, eyes closed: success moments such as "You're all set".
  done,
}

/// Onigiri, a rice ball with a nori band and one sakura petal on top.
///
/// Each pose is a local PNG in assets/images (with 2.0x and 3.0x copies
/// for sharp phones), drawn from the SVG sources in design/onigiri.
class Onigiri extends StatelessWidget {
  const Onigiri({
    super.key,
    this.pose = OnigiriPose.hello,
    this.size = 120,
    this.semanticLabel,
  });

  final OnigiriPose pose;

  /// Width and height in logical pixels.
  final double size;

  /// Null hides the mascot from screen readers (it is decoration).
  final String? semanticLabel;

  /// The asset path for a pose.
  static String assetFor(OnigiriPose pose) =>
      'assets/images/onigiri_${pose.name}.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetFor(pose),
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
