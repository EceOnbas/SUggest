import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../services/auth_service.dart';
import 'models/my_review.dart';
import 'my_profile_store.dart';
import 'widgets/my_review_card.dart';

/// The review actions My Profile and My Courses share, so both show the
/// same screens, questions and messages.
abstract final class ReviewActions {
  /// Opens Write Review. With [courseCode], that course is picked (or its
  /// review opens when there is one already).
  static Future<void> write(BuildContext context, {String? courseCode}) async {
    final review = await Navigator.pushNamed<MyReview>(
      context,
      AppRoutes.writeReview,
      arguments: courseCode,
    );
    if (review == null || !context.mounted) return;
    AppToast.show(
      context,
      review.edited == null
          ? 'Review submitted successfully.'
          : 'Review changes saved successfully.',
    );
  }

  static Future<void> edit(BuildContext context, MyReview review) async {
    final updated = await Navigator.pushNamed<MyReview>(
      context,
      AppRoutes.writeReview,
      arguments: review,
    );
    if (updated == null || !context.mounted) return;
    AppToast.show(context, 'Review changes saved successfully.');
  }

  /// Asks first, then deletes [review].
  static Future<void> delete(BuildContext context, MyReview review) async {
    final email = AuthScope.of(context).email;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Review?',
      message:
          'This action is permanent and cannot be undone. Your course '
          'ratings and feedback will be removed.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || email == null || !context.mounted) return;
    MyProfileStore.instance.deleteReview(email, review.id);
    AppToast.show(context, 'Review deleted.');
  }

  /// Shows [review] open in a sheet, with Edit and Delete.
  static Future<void> open(BuildContext context, MyReview review) async {
    final handle = AuthScope.of(context).handle;
    final choice = await showAppBottomSheet<_SheetChoice>(
      context: context,
      title: 'My review of ${review.courseCode}',
      builder: (sheet) => MyReviewCard(
        review: review,
        handle: handle,
        initiallyExpanded: true,
        onEdit: () => Navigator.pop(sheet, _SheetChoice.edit),
        onDelete: () => Navigator.pop(sheet, _SheetChoice.delete),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case _SheetChoice.edit:
        await edit(context, review);
      case _SheetChoice.delete:
        await delete(context, review);
      case null:
        break;
    }
  }
}

enum _SheetChoice { edit, delete }
