import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/state_views.dart';
import '../../models/course.dart';
import '../../models/review.dart';
import 'catalog_repository.dart';
import 'home_view.dart';
import 'search_view.dart';

/// The Courses tab: a shelf of courses, the latest reviews and search.
///
/// Search opens inside this tab, so the bottom bar stays visible. The
/// Android back button closes search before it leaves the app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.repository = const MockCatalogRepository(),
  });

  final CatalogRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

typedef _CatalogData = ({List<Course> courses, List<Review> reviews});

class _HomeScreenState extends State<HomeScreen> {
  late Future<_CatalogData> _data = _load();
  bool _searching = false;

  /// Lives here so recent searches survive closing and reopening search.
  List<String> _recent = const [];

  Future<_CatalogData> _load() async {
    final (courses, reviews) = await (
      widget.repository.fetchCourses(),
      widget.repository.fetchLatestReviews(),
    ).wait;
    return (courses: courses, reviews: reviews);
  }

  void _openCourse(Course course) => Navigator.of(
    context,
  ).pushNamed(AppRoutes.course, arguments: course.code);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _searching = false);
      },
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<_CatalogData>(
            future: _data,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (snapshot.hasError) {
                return _Message(
                  ErrorState(
                    title: "Courses didn't load",
                    onRetry: () => setState(() {
                      _data = _load();
                    }),
                  ),
                );
              }
              if (data == null) return const _Message(_HomeLoading());
              if (_searching) {
                return SearchView(
                  courses: data.courses,
                  recent: _recent,
                  onRecentChanged: (r) => setState(() => _recent = r),
                  onClose: () => setState(() => _searching = false),
                  onOpenCourse: _openCourse,
                );
              }
              return HomeView(
                courses: data.courses,
                reviews: data.reviews,
                onSearch: () => setState(() => _searching = true),
                onOpenCourse: _openCourse,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text('Courses', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.xl),
        child,
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: AppSpacing.inputHeight, radius: AppRadius.input),
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(width: 160, height: 22),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 150, radius: AppRadius.card),
        SizedBox(height: AppSpacing.xl),
        LoadingList(itemCount: 2, label: 'Loading courses'),
      ],
    );
  }
}
