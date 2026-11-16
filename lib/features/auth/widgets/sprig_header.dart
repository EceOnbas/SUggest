import 'package:flutter/material.dart';

import '../../../core/art/sakura_branch.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_back_button.dart';

/// The top of the sign-in screens: a back arrow and a small sakura sprig
/// growing in from the top right corner.
///
/// [height] is the space before the title. The sprig may reach below it
/// and sit behind the title, as in the design.
class SprigHeader extends StatelessWidget {
  const SprigHeader({
    super.key,
    required this.height,
    required this.sprig,
    this.onBack,
  });

  final double height;
  final SprigStyle sprig;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            right: 0,
            width: sprig.width,
            height: sprig.height,
            child: IgnorePointer(
              child: SakuraBranch(
                seed: sprig.seed,
                difficulty: sprig.difficulty,
                workload: sprig.workload,
                attendance: sprig.attendance,
                start: sprig.start,
                flowerScale: sprig.flowerScale,
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.pageGutter,
            child: AppBackButton(onPressed: onBack),
          ),
        ],
      ),
    );
  }
}

/// Size and shape of a corner sprig, copied from the design.
class SprigStyle {
  const SprigStyle({
    required this.seed,
    required this.width,
    required this.height,
    required this.start,
    this.difficulty = 3,
    this.workload = 3,
    this.attendance = 3,
    this.flowerScale = 1,
  });

  /// The larger sprig on Log in.
  static const login = SprigStyle(
    seed: 'SU sprig',
    width: 320,
    height: 290,
    workload: 2.8,
    attendance: 3.4,
    start: SakuraStart(x: 334, y: -10, angle: 2.35, length: 96),
    flowerScale: 0.62,
  );

  /// The smaller sprig on Create account.
  static const signUp = SprigStyle(
    seed: 'SU sprig 2',
    width: 220,
    height: 180,
    workload: 2.2,
    attendance: 3,
    start: SakuraStart(x: 232, y: -6, angle: 2.5, length: 62),
    flowerScale: 0.6,
  );

  final String seed;
  final double width;
  final double height;
  final SakuraStart start;
  final double difficulty;
  final double workload;
  final double attendance;
  final double flowerScale;
}
