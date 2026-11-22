import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../data/mock_data.dart';
import 'models/program_info.dart';
import 'program_post_store.dart';

/// "Programs": every major, double major and minor, picked with the chips
/// at the top. Tapping a program opens its page.
///
/// Open it with `Navigator.pushNamed(context, AppRoutes.programs)`.
class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  ProgramType _type = ProgramType.major;

  /// The program names for the picked type, from the shared mock data.
  List<String> get _names => switch (_type) {
    ProgramType.major => MockData.majors,
    ProgramType.doubleMajor => MockData.doubleMajors,
    ProgramType.minor => MockData.minors,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          // Rebuild when posts change, so the post counts stay right.
          listenable: ProgramPostStore.instance,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Row(
                children: [
                  const AppBackButton(),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Programs',
                        style: AppTextStyles.heading.copyWith(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'See the usual course route of a program and what students '
                'in it share.',
                style: AppTextStyles.helper,
              ),
              const SizedBox(height: AppSpacing.lg),
              ChipFilterRow(
                options: [for (final t in ProgramType.values) t.label],
                selected: _type.label,
                onSelected: (label) => setState(() {
                  _type = ProgramType.values.firstWhere(
                    (t) => t.label == label,
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final name in _names) ...[
                _ProgramCard(
                  name: name,
                  postCount: ProgramPostStore.instance.postsFor(name).length,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.program,
                    arguments: ProgramRef(name: name, type: _type),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One program in the list: its name, how many posts it has, and an
/// arrow that shows it opens.
class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.name,
    required this.postCount,
    required this.onTap,
  });

  final String name;
  final int postCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyStrong),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  postCount == 1 ? '1 post' : '$postCount posts',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
