import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import 'edit_account_sheet.dart';
import 'edit_academic_screen.dart';
import 'models/my_course.dart';
import 'models/my_review.dart';
import 'models/profile_details.dart';
import 'my_courses_screen.dart';
import 'my_profile_store.dart';
import 'review_actions.dart';
import 'utils/search_text.dart';
import 'widgets/my_review_card.dart';
import 'widgets/profile_widgets.dart';

/// Profile tab: account and contact details, academic information,
/// courses taken and the student's own reviews.
///
/// - "Edit" on the account card opens a bottom sheet form.
/// - "Edit" or a "+ Add" button on the academic card opens Edit
///   Academic Info.
/// - "Manage" on Courses Taken opens My Courses.
/// - "+ Write Review" and "Edit Review" open the review form; "Delete
///   Review" asks first.
///
/// The setup answers and handle come from the auth service; contact
/// details, graduation and reviews from [MyProfileStore]. A new account
/// starts empty.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _search = TextEditingController();
  final _store = MyProfileStore.instance;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  AuthService get _auth => AuthScope.of(context);
  String get _email => _auth.email ?? '';
  MyProfileData get _data => _store.dataFor(_email);
  List<MyReview> get _reviews => _store.reviewsOf(_email);

  AccountDetails get _account => AccountDetails(
    fullName: _data.fullName,
    handle: _auth.handle ?? '',
    institutionalEmail: _email,
    backupEmail: _data.backupEmail,
    phone: _data.phone,
  );

  AcademicDetails get _academic => AcademicDetails.fromProfile(
    _auth.profile ?? const UserProfile(),
    graduated: _data.graduated,
    graduationYear: _data.graduationYear,
  );

  /// Newest first (by the latest of posted and edited), then filtered by
  /// the search box.
  List<MyReview> get _shownReviews {
    final sorted = [..._reviews]
      ..sort((a, b) => b.lastChanged.compareTo(a.lastChanged));
    return [
      for (final r in sorted)
        if (matchesSearch(r.searchText, _search.text)) r,
    ];
  }

  Future<void> _logOut() async {
    await AuthScope.of(context).logOut();
    if (mounted) await AppRoutes.restart(context);
  }

  /// The handle is saved by the sheet itself; the rest is saved here.
  Future<void> _editAccount() async {
    final updated = await showEditAccountSheet(context, _account);
    if (updated == null || !mounted) return;
    _store.saveContact(
      _email,
      fullName: updated.fullName,
      backupEmail: updated.backupEmail,
      phone: updated.phone,
    );
    AppToast.show(context, 'Account details updated successfully.');
  }

  /// Saves the programs, terms and exchanges back to the setup answers;
  /// graduation stays in [MyProfileStore].
  Future<void> _editAcademic([AcademicExtra? focus]) async {
    final updated = await Navigator.pushNamed<AcademicDetails>(
      context,
      AppRoutes.editAcademic,
      arguments: EditAcademicArgs(_academic, focus: focus),
    );
    if (updated == null || !mounted) return;
    final auth = _auth;
    final email = _email;
    await auth.saveProfile(
      updated.applyTo(auth.profile ?? const UserProfile()),
    );
    _store.saveGraduation(
      email,
      graduated: updated.graduated,
      graduationYear: updated.graduationYear,
    );
    if (!mounted) return;
    AppToast.show(context, 'Academic information updated successfully.');
  }

  Future<void> _openMyCourses() =>
      Navigator.pushNamed(context, AppRoutes.myCourses);

  Future<void> _writeReview() => ReviewActions.write(context);

  void _clearSearch() => setState(_search.clear);

  /// The gear: shortcuts to the edit screens and Log out.
  Future<void> _openSettings() async {
    final choice = await showAppBottomSheet<_SettingsChoice>(
      context: context,
      title: 'Settings',
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final choice in _SettingsChoice.values) ...[
            SecondaryButton(
              label: choice.label,
              compact: true,
              onPressed: () => Navigator.pop(context, choice),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
    switch (choice) {
      case _SettingsChoice.account:
        await _editAccount();
      case _SettingsChoice.academic:
        await _editAcademic();
      case _SettingsChoice.myCourses:
        await _openMyCourses();
      case _SettingsChoice.logOut:
        await _logOut();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Depend on the auth service, so a saved profile or handle rebuilds.
    AuthScope.of(context);
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onLogOut: _logOut, onSettings: _openSettings),
                const SizedBox(height: 20),
                _buildAccountCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildAcademicCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildCoursesCard(),
                const SizedBox(height: 28),
                ..._buildReviews(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    String orDash(String value) => value.isEmpty ? '—' : value;
    final account = _account;
    return ProfileSectionCard(
      title: 'Account & Contact Details',
      onEdit: _editAccount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(label: 'Full Name', lines: [orDash(account.fullName)]),
          InfoRow(
            label: 'Handle',
            lines: [account.handle.isEmpty ? '—' : '@${account.handle}'],
          ),
          InfoRow(
            label: 'Institutional Email',
            lines: [account.institutionalEmail],
          ),
          InfoRow(label: 'Backup Email', lines: [orDash(account.backupEmail)]),
          InfoRow(label: 'Phone Number', lines: [orDash(account.phone)]),
          const PrivacyNote(),
        ],
      ),
    );
  }

  Widget _buildAcademicCard() {
    final academic = _academic;
    final missing = [
      for (final field in AcademicExtra.values)
        if (academic.extra(field).isEmpty) field,
    ];
    return ProfileSectionCard(
      title: 'Academic Information',
      onEdit: _editAcademic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(
            label: 'Primary Program (Major)',
            lines: [academic.major.isEmpty ? '—' : academic.major],
          ),
          InfoRow(
            label: 'Academic Status & Timeline',
            lines: academic.timelineLines,
          ),
          for (final field in AcademicExtra.values)
            if (academic.extra(field).isNotEmpty)
              InfoRow(label: field.label, lines: academic.linesOf(field)),
          for (final field in missing)
            AddFieldButton(
              label: '+ Add ${field.label}',
              onPressed: () => _editAcademic(field),
            ),
        ],
      ),
    );
  }

  /// A summary of My Courses: how many, how many still to review, and
  /// the most recent term's courses.
  Widget _buildCoursesCard() {
    final courses = MyCourse.allOf(_auth.profile);
    final reviewed = {for (final r in _reviews) r.courseCode};
    final latest = courses.isEmpty ? null : courses.first.term;
    return ProfileSectionCard(
      title: 'Courses Taken',
      actionLabel: 'Manage',
      onEdit: _openMyCourses,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (latest == null) ...[
            Text(
              'Add the courses you finished to review them.',
              style: AppTextStyles.helper,
            ),
            AddFieldButton(label: '+ Add Courses', onPressed: _openMyCourses),
          ] else ...[
            InfoRow(
              label: 'Summary',
              lines: [MyCoursesScreen.coursesSummary(courses, reviewed)],
            ),
            InfoRow(
              label: 'Most Recent Term: $latest',
              lines: [
                for (final c in courses)
                  if (c.term == latest) c.label,
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildReviews() {
    final shown = _shownReviews;
    return [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          Semantics(
            header: true,
            child: Text('My Reviews', style: AppTextStyles.heading),
          ),
          TextButton(
            onPressed: _writeReview,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              textStyle: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('+ Write Review'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      if (_reviews.isNotEmpty) ...[
        AppTextField(
          label: 'Search my reviews',
          controller: _search,
          hintText: 'Search course, instructor, or term...',
          textInputAction: TextInputAction.search,
          boxPadding: const EdgeInsets.only(left: 18, right: 4),
          onChanged: (_) => setState(() {}),
          suffix: _search.text.isEmpty
              ? const Icon(Icons.search_rounded, color: AppColors.muted)
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
      if (_reviews.isEmpty)
        EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message: 'You have not posted any reviews yet.',
          actionLabel: 'Write a review',
          onAction: _writeReview,
        )
      else if (shown.isEmpty)
        EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No reviews found',
          message: 'No reviews found matching your search.',
          actionLabel: 'Clear search',
          onAction: _clearSearch,
        ),
      for (final (i, review) in shown.indexed) ...[
        if (i > 0) const SizedBox(height: AppSpacing.md),
        MyReviewCard(
          key: ValueKey(review.id),
          review: review,
          handle: _auth.handle,
          onEdit: () => ReviewActions.edit(context, review),
          onDelete: () => ReviewActions.delete(context, review),
        ),
      ],
    ];
  }
}

/// The options in the Settings sheet.
enum _SettingsChoice {
  account('Edit account details'),
  academic('Edit academic info'),
  myCourses('My Courses'),
  logOut('Log out');

  const _SettingsChoice(this.label);
  final String label;
}

/// "My Profile" with the Log out pill and the settings gear. The buttons
/// move under the title when they do not fit beside it.
class _Header extends StatelessWidget {
  const _Header({required this.onLogOut, required this.onSettings});

  final VoidCallback onLogOut;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        Semantics(
          header: true,
          child: Text('My Profile', style: AppTextStyles.stepTitle),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              style: compactPillStyle(),
              onPressed: onLogOut,
              child: const Text('Log out'),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              tooltip: 'Settings',
              onPressed: onSettings,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceMuted,
                side: const BorderSide(color: AppColors.borderStrong),
                minimumSize: const Size(AppSpacing.minTap, AppSpacing.minTap),
              ),
              icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
            ),
          ],
        ),
      ],
    );
  }
}
