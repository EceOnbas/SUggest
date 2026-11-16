import 'package:flutter/material.dart';

import '../../core/art/sakura_branch.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/su_email.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

/// The first screen when no one is signed in: a band at the top, the app
/// name and its promise, and the two ways in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 400 on a tall phone, smaller on short ones so the buttons fit.
            final bandHeight = (constraints.maxHeight * 0.47).clamp(
              220.0,
              400.0,
            );
            return FillScrollView(
              top: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: bandHeight, child: const WelcomeBand()),
                  // The text starts a little inside the band's fade.
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: const _Intro(),
                  ),
                ],
              ),
              bottom: const _Actions(),
            );
          },
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUggest', style: AppTextStyles.wordmark),
          const SizedBox(height: 18),
          Semantics(
            header: true,
            child: Text(
              'Know the course before you register.',
              style: AppTextStyles.display,
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Ratings and reviews from Sabancı students, checked against '
              'a school email.',
              style: AppTextStyles.lead,
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.lg,
        AppSpacing.pageGutter,
        36,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: 'Create account',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Log in',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
          const SizedBox(height: 14),
          Text(
            'For ${SuEmail.domain} accounts only.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// The top band: a campus photo loaded from the network.
///
/// While the photo loads, and whenever it cannot load (for example with
/// no internet), the sakura branch from the design shows instead. The
/// photo fades in over the branch and covers it once it is ready.
class WelcomeBand extends StatelessWidget {
  const WelcomeBand({super.key, this.photoUrl = campusPhotoUrl});

  /// Beren's campus photo, stored in the repository (docs/images) and
  /// pinned to the commit that added it so the address never changes.
  static const campusPhotoUrl =
      'https://raw.githubusercontent.com/EceOnbas/SUggest/'
      '7df0464cd164f4811ee76969f7bb0833d2ce9337/'
      'docs/images/welcome_campus.jpg';

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const SakuraBranch(seed: 'SUggest', difficulty: 3, attendance: 3.5),
        Image.network(
          photoUrl,
          fit: BoxFit.cover,
          // Decode only as many pixels as the screen shows.
          cacheWidth: (width * pixelRatio).round(),
          excludeFromSemantics: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: child,
            );
          },
          // No photo: show nothing here, so the branch stays visible.
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        // Fades the band into the page background at the bottom.
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 150,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.85],
                  colors: [Color(0x00EDEFF2), AppColors.background],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
