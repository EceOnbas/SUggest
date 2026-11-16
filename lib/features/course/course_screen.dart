import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../data/course_repository.dart';
import '../../models/course.dart';
import 'overview_tab.dart';
import 'widgets/course_header.dart';
import 'widgets/course_tab_bar.dart';

/// The course page: a header with the course's sakura branch, then the
/// Overview, Sections and Reviews tabs.
///
/// Open it with
/// `Navigator.pushNamed(context, AppRoutes.course, arguments: 'CS 310')`.
class CourseScreen extends StatefulWidget {
  const CourseScreen({
    super.key,
    required this.courseCode,
    this.repository = const MockCourseRepository(),
  });

  final String courseCode;

  /// Where the course comes from: placeholder data in Step 2, Firebase in
  /// Step 3.
  final CourseRepository repository;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late Future<Course> _course;
  CourseTab _tab = CourseTab.overview;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _course = widget.repository.fetchCourse(widget.courseCode);
  }

  void _toggleSaved() {
    setState(() => _saved = !_saved);
    AppToast.show(
      context,
      _saved ? 'Course saved.' : 'Removed from saved courses.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Course>(
      future: _course,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _MessagePage(
            child: LoadingList(label: 'Loading course'),
          );
        }
        if (snapshot.error is CourseNotFoundException) {
          return _MessagePage(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Course not found',
              message: '${widget.courseCode} is not in the catalog.',
            ),
          );
        }
        if (snapshot.hasError) {
          return _MessagePage(
            child: ErrorState(onRetry: () => setState(_load)),
          );
        }
        return _buildPage(context, snapshot.requireData);
      },
    );
  }

  Widget _buildPage(BuildContext context, Course course) {
    // The tab bar is 48 px tall and grows with the user's text size.
    final tabBarHeight =
        math.max(48.0, MediaQuery.textScalerOf(context).scale(16) * 1.2 + 20) +
        1;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CourseHeader(
                course: course,
                saved: _saved,
                onToggleSaved: _toggleSaved,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverPersistentHeader(
              pinned: true,
              delegate: CourseTabBarDelegate(
                height: tabBarHeight,
                child: CourseTabBar(
                  selected: _tab,
                  onSelected: (tab) => setState(() => _tab = tab),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              sliver: SliverToBoxAdapter(child: _buildTab(course)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _WriteReviewBar(),
    );
  }

  Widget _buildTab(Course course) => switch (_tab) {
    CourseTab.overview => OverviewTab(course: course),
    CourseTab.sections => const EmptyState(title: 'Sections'),
    CourseTab.reviews => const EmptyState(title: 'Reviews'),
  };
}

/// A plain page with a back arrow, used while the course loads or when it
/// cannot be shown.
class _MessagePage extends StatelessWidget {
  const _MessagePage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(),
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

/// The bar that keeps "Write a review" at the bottom of the screen.
class _WriteReviewBar extends StatelessWidget {
  const _WriteReviewBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(top: BorderSide(color: AppColors.borderStrong)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: PrimaryButton(
            label: 'Write a review',
            // The review form is a teammate's screen; it opens from here
            // once it is added.
            onPressed: () => AppToast.show(
              context,
              'Writing a review opens here once that screen is added.',
            ),
          ),
        ),
      ),
    );
  }
}
