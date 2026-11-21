import 'package:flutter/foundation.dart';

import 'models/my_review.dart';
import 'profile_mock_data.dart';

/// What My Profile keeps for one account besides the setup answers
/// (those stay in `AuthService.profile`).
class MyProfileData {
  MyProfileData({
    this.fullName = '',
    this.backupEmail = '',
    this.phone = '',
    this.graduated = false,
    this.graduationYear = '2026',
    List<MyReview> reviews = const [],
  }) : reviews = [...reviews];

  String fullName;
  String backupEmail;
  String phone;
  bool graduated;

  /// For example "2024"; used only when [graduated].
  String graduationYear;

  /// The student's own reviews, in the order they were added.
  final List<MyReview> reviews;
}

/// The one place My Profile, My Courses and Write Review read and save
/// contact details, graduation and the student's reviews, by account
/// email. A new account starts empty; only the showcase account starts
/// with [ProfileMockData]'s placeholders.
///
/// Step 2 keeps everything in memory. Step 3 replaces this with
/// Firestore.
class MyProfileStore extends ChangeNotifier {
  MyProfileStore._();

  static final instance = MyProfileStore._();

  final Map<String, MyProfileData> _data = {};

  /// The data of [email], made on first use.
  MyProfileData dataFor(String email) =>
      _data.putIfAbsent(email, () => ProfileMockData.startingDataFor(email));

  List<MyReview> reviewsOf(String email) =>
      List.unmodifiable(dataFor(email).reviews);

  /// The review of [courseCode] by [email], or null. A course has at
  /// most one review.
  MyReview? reviewFor(String email, String courseCode) {
    for (final r in dataFor(email).reviews) {
      if (r.courseCode == courseCode) return r;
    }
    return null;
  }

  void saveContact(
    String email, {
    required String fullName,
    required String backupEmail,
    required String phone,
  }) {
    dataFor(email)
      ..fullName = fullName
      ..backupEmail = backupEmail
      ..phone = phone;
    notifyListeners();
  }

  void saveGraduation(
    String email, {
    required bool graduated,
    required String graduationYear,
  }) {
    dataFor(email)
      ..graduated = graduated
      ..graduationYear = graduationYear;
    notifyListeners();
  }

  /// Adds [review], or replaces the review with the same id.
  void saveReview(String email, MyReview review) {
    final reviews = dataFor(email).reviews;
    final i = reviews.indexWhere((r) => r.id == review.id);
    if (i >= 0) {
      reviews[i] = review;
    } else {
      reviews.add(review);
    }
    notifyListeners();
  }

  void deleteReview(String email, String reviewId) {
    dataFor(email).reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }

  /// Forgets everything, so each test starts fresh.
  @visibleForTesting
  void reset() => _data.clear();
}
