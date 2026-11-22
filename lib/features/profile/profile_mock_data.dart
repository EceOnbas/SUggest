import '../../core/utils/su_email.dart';
import '../../models/review_topic.dart';
import '../../services/fake_auth_service.dart';
import 'models/my_review.dart';
import 'my_profile_store.dart';

/// Placeholder data used only by My Profile and Write Review in Step 2.
///
/// Courses, terms, majors, minors and universities come from `MockData`;
/// the showcase account's setup answers and handle live in
/// [FakeAuthService]. This file only adds what My Profile needs on top:
/// the showcase student's contact details and reviews. Firebase replaces
/// it in Step 3.
abstract final class ProfileMockData {
  /// The full address of the showcase account.
  static final showcaseEmail = SuEmail.full(FakeAuthService.showcaseAccount);

  /// "Class of 2026" back to "Class of 2021".
  static const graduationYears = [
    '2026',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
  ];

  /// Extra search words for some courses, by course code. They only
  /// help find a course; the course's own name is what is saved.
  static const courseAliases = {
    'CS 310': ['mobile app development'],
    'CS 201': ['intro to computing'],
    'CS 300': ['ds', 'algorithms'],
    'MATH 102': ['calc 2'],
    'MATH 201': ['linear algebra', 'linalg'],
  };

  /// What My Profile starts with for [email]: empty for every account
  /// except the showcase one.
  static MyProfileData startingDataFor(String email) {
    if (email != showcaseEmail) return MyProfileData();
    return MyProfileData(
      fullName: 'Deniz Yılmaz',
      backupEmail: 'deniz.backup@gmail.com',
      phone: '+90 532 555 0199',
      reviews: showcaseReviews,
    );
  }

  /// The showcase student's reviews. Each one is for a course on their
  /// My Courses list, with the same term and instructor.
  static final showcaseReviews = [
    MyReview(
      id: 'my-1',
      courseCode: 'CS 310',
      courseTitle: 'Mobile Application Development',
      term: 'Fall 2025',
      instructor: 'Instructor A',
      posted: DateTime(2026, 1, 18),
      ratings: const {
        ReviewTopic.difficulty: 4,
        ReviewTopic.workload: 4,
        ReviewTopic.instructor: 4,
        ReviewTopic.attendance: 3,
      },
      tags: const [ReviewTopic.workload, ReviewTopic.instructor],
      feedback:
          'The course load was manageable during the first half, but the '
          'final project required a tremendous amount of teamwork. Overall, '
          'Instructor A is responsive and helpful during office hours.',
    ),
    MyReview(
      id: 'my-2',
      courseCode: 'MATH 201',
      courseTitle: 'Linear Algebra',
      term: 'Fall 2025',
      instructor: 'Instructor B',
      posted: DateTime(2026, 1, 24),
      edited: DateTime(2026, 9, 10),
      ratings: const {
        ReviewTopic.difficulty: 4,
        ReviewTopic.workload: 4,
        ReviewTopic.instructor: 5,
        ReviewTopic.attendance: 2,
      },
      tags: const [ReviewTopic.instructor, ReviewTopic.difficulty],
      feedback:
          'Instructor B explains abstract concepts exceptionally well. '
          'Midterms were quite tough, but homework assignments prepared us '
          'properly for the final exam. Attendance is not strictly taken.',
    ),
  ];
}
