import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../data/mock_data.dart';
import '../../services/auth_service.dart';
import 'models/program_info.dart';
import 'models/program_post.dart';
import 'program_mock_data.dart';
import 'program_post_store.dart';
import 'widgets/post_card.dart';
import 'widgets/write_post_form.dart';

/// One program's page, with two tabs:
///
/// - **Usual route**: the courses most students take in each term.
///   Tapping a course opens its course page.
/// - **Posts**: what students of the program share. "Write a post" opens
///   a form in a bottom sheet.
///
/// Open it with `Navigator.pushNamed(context, AppRoutes.program,
/// arguments: ProgramRef(...))`.
class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key, required this.program});

  final ProgramRef program;

  static const routeTab = 'Usual route';
  static const postsTab = 'Posts';

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  String _tab = ProgramScreen.routeTab;

  Future<void> _writePost() async {
    final draft = await showAppBottomSheet<PostDraft>(
      context: context,
      title: 'Write a post',
      builder: (_) => const WritePostForm(),
    );
    if (draft == null || !mounted) return;
    ProgramPostStore.instance.add(
      programName: widget.program.name,
      topic: draft.topic,
      text: draft.text,
      term: MockData.currentTerm,
      authorHandle: AuthScope.of(context).handle,
    );
    setState(() => _tab = ProgramScreen.postsTab);
    AppToast.show(context, 'Your post is shared.');
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ProgramPostStore.instance,
          builder: (context, _) {
            final posts = ProgramPostStore.instance.postsFor(program.name);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(program.type.label, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xs),
                Semantics(
                  header: true,
                  child: Text(program.name, style: AppTextStyles.courseTitle),
                ),
                const SizedBox(height: AppSpacing.lg),
                ChipFilterRow(
                  options: [
                    ProgramScreen.routeTab,
                    '${ProgramScreen.postsTab} (${posts.length})',
                  ],
                  selected: _tab == ProgramScreen.routeTab
                      ? ProgramScreen.routeTab
                      : '${ProgramScreen.postsTab} (${posts.length})',
                  onSelected: (label) => setState(() {
                    _tab = label == ProgramScreen.routeTab
                        ? ProgramScreen.routeTab
                        : ProgramScreen.postsTab;
                  }),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_tab == ProgramScreen.routeTab)
                  ..._buildRoute(context)
                else
                  ..._buildPosts(posts),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildRoute(BuildContext context) {
    final terms = ProgramMockData.routeFor(widget.program.name);
    return [
      Text(
        'What most students in this program take each term. Your own '
        'route can be different.',
        style: AppTextStyles.helper,
      ),
      const SizedBox(height: AppSpacing.md),
      for (final term in terms) ...[
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(term.label, style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.sm),
              for (final code in term.courseCodes) _RouteCourse(code: code),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }

  List<Widget> _buildPosts(List<ProgramPost> posts) {
    return [
      PrimaryButton(label: 'Write a post', onPressed: _writePost),
      const SizedBox(height: AppSpacing.lg),
      if (posts.isEmpty)
        const EmptyState(
          icon: Icons.forum_outlined,
          title: 'No posts yet',
          message: 'Ask a question or share advice about this program.',
        ),
      for (final post in posts) ...[
        PostCard(post: post),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }
}

/// A course in the usual route. Opens the course page when tapped.
class _RouteCourse extends StatelessWidget {
  const _RouteCourse({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final course = MockData.courseByCode(code);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.input),
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.course, arguments: code),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
        child: Row(
          children: [
            Expanded(
              child: Text(
                course?.fullName ?? code,
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
