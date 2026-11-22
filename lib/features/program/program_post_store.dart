import 'package:flutter/foundation.dart';

import 'models/program_post.dart';
import 'program_mock_data.dart';

/// Keeps the program posts while the app runs, so a post written on a
/// program page shows up on the admin screen, and a post the admin
/// removes disappears from the program page.
///
/// Screens listen to it with a `ListenableBuilder`. Firebase replaces it
/// in Step 3.
class ProgramPostStore extends ChangeNotifier {
  ProgramPostStore._();

  static final instance = ProgramPostStore._();

  final List<ProgramPost> _posts = [...ProgramMockData.posts];
  int _nextId = 100;

  /// All posts, newest first.
  List<ProgramPost> get all => List.unmodifiable(_posts);

  List<ProgramPost> postsFor(String programName) =>
      _posts.where((p) => p.programName == programName).toList();

  /// Adds a post at the top and returns it.
  ProgramPost add({
    required String programName,
    required String topic,
    required String text,
    required String term,
    String? authorHandle,
  }) {
    final post = ProgramPost(
      id: 'p${_nextId++}',
      programName: programName,
      topic: topic,
      text: text,
      term: term,
      authorHandle: authorHandle,
    );
    _posts.insert(0, post);
    notifyListeners();
    return post;
  }

  void remove(String id) {
    _posts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Puts the starting posts back. Used by tests.
  void reset() {
    _posts
      ..clear()
      ..addAll(ProgramMockData.posts);
    notifyListeners();
  }
}
