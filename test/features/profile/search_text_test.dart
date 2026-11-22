import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/data/mock_data.dart';
import 'package:suggest/features/profile/models/my_course.dart';
import 'package:suggest/features/profile/models/my_review.dart';
import 'package:suggest/features/profile/models/profile_details.dart';
import 'package:suggest/features/profile/profile_mock_data.dart';
import 'package:suggest/features/profile/utils/search_text.dart';
import 'package:suggest/models/review_topic.dart';
import 'package:suggest/models/user_profile.dart';
import 'package:suggest/services/fake_auth_service.dart';

void main() {
  group('normalizeSearchText', () {
    test('lower case, no accents, symbols become one space', () {
      expect(normalizeSearchText('CS-310 · Mobile'), 'cs 310 mobile');
      expect(normalizeSearchText('Deniz Yılmaz'), 'deniz yilmaz');
      expect(normalizeSearchText('  İstanbul Şehir  '), 'istanbul sehir');
    });
  });

  group('matchesSearch', () {
    const text =
        'CS 310 · Mobile Application Development Fall 2023 '
        'Instructor A';

    test('empty query matches everything', () {
      expect(matchesSearch(text, ''), isTrue);
      expect(matchesSearch(text, '   '), isTrue);
    });

    test('a phrase matches as typed or without spaces', () {
      expect(matchesSearch(text, 'mobile app'), isTrue);
      expect(matchesSearch(text, 'cs310'), isTrue);
      expect(matchesSearch(text, 'CS-310'), isTrue);
    });

    test('several words match in any order', () {
      expect(matchesSearch(text, 'fall mobile'), isTrue);
      expect(matchesSearch(text, 'spring mobile'), isFalse);
    });

    test('unrelated text does not match', () {
      expect(matchesSearch(text, 'linear algebra'), isFalse);
    });
  });

  group('rating words', () {
    test("match the course page's words, with a capital letter", () {
      for (final topic in RatingScale.order) {
        for (var score = 1; score <= 5; score++) {
          expect(
            topic.wordForScore(score).toLowerCase(),
            topic.wordFor(score.toDouble()),
          );
        }
      }
      expect(ReviewTopic.difficulty.wordForScore(4), 'Fairly hard');
      expect(ReviewTopic.attendance.wordForScore(9), 'Always taken');
      expect(ReviewTopic.instructor.wordForScore(0), 'Poor');
    });

    test('dates read like "Oct 12, 2024"', () {
      expect(formatReviewDate(DateTime(2024, 10, 12)), 'Oct 12, 2024');
      expect(formatReviewDate(DateTime(2023, 6, 2)), 'Jun 02, 2023');
    });
  });

  group('AcademicDetails', () {
    const profile = UserProfile(
      major: 'Economics',
      minor: 'Mathematics',
      classYear: '2',
      currentTerm: 'Spring 2027',
      startTerm: 'Fall 2025',
      exchanges: [
        ExchangeInfo(
          hostUniversity: 'TU Delft, Netherlands',
          term: 'Fall 2025',
          program: ExchangeProgram.erasmus,
        ),
        ExchangeInfo(
          hostUniversity: 'National University of Singapore',
          term: 'Spring 2026',
          program: ExchangeProgram.exchange,
        ),
      ],
    );

    test('copies the setup answers, with both exchanges', () {
      final details = AcademicDetails.fromProfile(profile);
      expect(details.major, 'Economics');
      expect(details.extra(AcademicExtra.minor), 'Mathematics');
      expect(details.extra(AcademicExtra.doubleMajor), isEmpty);
      expect(details.linesOf(AcademicExtra.erasmus), [
        'TU Delft, Netherlands',
        'Fall 2025',
      ]);
      expect(details.linesOf(AcademicExtra.exchange), [
        'National University of Singapore',
        'Spring 2026',
      ]);
      expect(details.timelineLines, [
        '2nd Year Student',
        'Current term: Spring 2027',
        'Started in Fall 2025',
      ]);
    });

    test('graduates show their class and start term', () {
      final details = AcademicDetails.fromProfile(
        profile,
        graduated: true,
        graduationYear: '2024',
      );
      expect(details.timelineLines, [
        'Graduated (Class of 2024)',
        'Started in Fall 2025',
      ]);
    });

    test('saves back to the profile, keeping courses taken', () {
      const taken = TakenCourse(
        courseName: 'CS 201 Introduction to Computing',
        term: 'Fall 2025',
        instructor: 'Instructor B',
      );
      final start = profile.copyWith(coursesTaken: const [taken]);
      final edited = AcademicDetails.fromProfile(start).copyWith(
        major: 'Management',
        currentTerm: 'Fall 2026',
        extras: const {AcademicExtra.minor: 'Physics'},
        exchangeTerms: const {},
      );
      final saved = edited.applyTo(start);
      expect(saved.major, 'Management');
      expect(saved.minor, 'Physics');
      expect(saved.doubleMajor, isNull);
      expect(saved.currentTerm, 'Fall 2026');
      expect(saved.startTerm, 'Fall 2025');
      expect(saved.exchanges, isEmpty);
      expect(saved.coursesTaken, [taken]);
    });
  });

  group('My Courses', () {
    test('terms sort by year, Fall after Spring', () {
      expect(compareTerms('Fall 2025', 'Spring 2025'), greaterThan(0));
      expect(compareTerms('Spring 2026', 'Fall 2025'), greaterThan(0));
      expect(compareTerms('Fall 2024', 'Fall 2024'), 0);
    });

    test('only finished terms since the start term can be picked', () {
      const profile = UserProfile(
        currentTerm: 'Fall 2026',
        startTerm: 'Fall 2024',
      );
      expect(finishedTermsFor(profile), [
        'Spring 2026',
        'Fall 2025',
        'Spring 2025',
        'Fall 2024',
      ]);
      expect(finishedTermsFor(null), isNot(contains(MockData.currentTerm)));
      // The app's own current term is never finished, even for a
      // student whose current term is later.
      expect(
        finishedTermsFor(const UserProfile(currentTerm: 'Spring 2027')),
        isNot(contains('Fall 2026')),
      );
    });

    test('courses come newest term first', () {
      final courses = MyCourse.allOf(FakeAuthService.showcaseProfile);
      final terms = [for (final c in courses) c.term];
      final sorted = [...terms]..sort((a, b) => compareTerms(b, a));
      expect(terms, sorted);
      for (final c in courses) {
        expect(c.course, isNotNull, reason: '${c.code} is in MockData');
      }
    });

    test("the showcase reviews match the showcase student's courses", () {
      final courses = {
        for (final c in MyCourse.allOf(FakeAuthService.showcaseProfile))
          c.code: c,
      };
      for (final review in ProfileMockData.showcaseReviews) {
        final course = courses[review.courseCode];
        expect(course, isNotNull, reason: review.courseCode);
        expect(review.term, course!.term);
        expect(review.instructor, course.instructor);
        expect(review.courseTitle, course.title);
      }
    });
  });
}
