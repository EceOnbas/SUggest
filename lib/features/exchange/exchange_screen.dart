import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/note_box.dart';
import '../../core/widgets/segmented_choice.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/text_link.dart';
import 'exchange_map.dart';
import 'exchange_models.dart';
import 'exchange_repository.dart';
import 'geo.dart';

/// Where Sabancı students go on Erasmus and exchange, as two maps
/// (Europe and the world) with moderated experience posts underneath.
class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({
    super.key,
    this.repository = const MockExchangeRepository(),
  });

  final ExchangeRepository repository;

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

typedef _ExchangeData = ({
  List<Destination> europe,
  List<Destination> world,
  List<ExchangePost> posts,
});

class _ExchangeScreenState extends State<ExchangeScreen> {
  late Future<_ExchangeData> _data = _load();
  MapRegion _region = MapRegion.europe;
  String? _school;
  String _topic = exchangeTopics.first;

  Future<_ExchangeData> _load() async {
    final (europe, world, posts) = await (
      widget.repository.fetchDestinations(MapRegion.europe),
      widget.repository.fetchDestinations(MapRegion.world),
      widget.repository.fetchPosts(),
    ).wait;
    return (europe: europe, world: world, posts: posts);
  }

  void _retry() => setState(() => _data = _load());

  void _pickRegion(MapRegion region) => setState(() {
    _region = region;
    _school = null;
    _topic = exchangeTopics.first;
  });

  void _toggleSchool(String school) => setState(() {
    _school = _school == school ? null : school;
    _topic = exchangeTopics.first;
  });

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
            const SizedBox(height: AppSpacing.sm),
            Text('Exchange', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Erasmus and exchange experiences from Sabancı students.',
              style: AppTextStyles.lead,
            ),
            const SizedBox(height: AppSpacing.xl),
            FutureBuilder<_ExchangeData>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorState(
                    title: "The exchange forum didn't load",
                    onRetry: _retry,
                  );
                }
                final data = snapshot.data;
                if (data == null) return const _ExchangeLoading();
                return _content(data);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(_ExchangeData data) {
    final destinations = _region == MapRegion.europe ? data.europe : data.world;
    final regionSchools = {for (final d in destinations) d.school};
    final selected = destinations
        .where((d) => d.school == _school)
        .firstOrNull;

    var posts = [
      for (final p in data.posts)
        if (regionSchools.contains(p.school)) p,
    ];
    if (selected != null) {
      posts = [
        for (final p in posts)
          if (p.school == selected.school) p,
      ];
    }
    if (_topic != exchangeTopics.first) {
      posts = [
        for (final p in posts)
          if (p.topics.contains(_topic)) p,
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Where students go', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.md),
        SegmentedChoice<MapRegion>(
          options: MapRegion.values,
          value: _region,
          onChanged: _pickRegion,
          labelOf: (r) =>
              r == MapRegion.europe ? 'Erasmus, Europe' : 'Exchange, world',
          semanticLabel: 'Map',
        ),
        const SizedBox(height: AppSpacing.md),
        ExchangeMap(
          region: _region,
          destinations: destinations,
          selected: selected?.school,
          onSelected: (d) => _toggleSchool(d.school),
        ),
        const SizedBox(height: AppSpacing.md),
        ChipFilterRow(
          options: [for (final d in destinations) d.school],
          selected: selected?.school ?? '',
          onSelected: _toggleSchool,
        ),
        const SizedBox(height: AppSpacing.md),
        _Summary(destinations: destinations, selected: selected),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Dot size shows how many students went. Schools with fewer than '
          '$minStudentsToShow students are not shown.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(child: Text('Posts', style: AppTextStyles.heading)),
            if (selected != null)
              TextLink(
                label: 'Show all',
                onPressed: () => setState(() => _school = null),
              ),
          ],
        ),
        if (selected != null)
          Text('Showing ${selected.school}', style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.md),
        ChipFilterRow(
          options: exchangeTopics,
          selected: _topic,
          onSelected: (t) => setState(() => _topic = t),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (posts.isEmpty)
          EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No posts here yet',
            message: _topic == exchangeTopics.first
                ? 'Nobody has shared what it was like at this school.'
                : 'No posts about ${_topic.toLowerCase()} yet.',
          )
        else
          for (final (i, post) in posts.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _PostCard(post: post),
          ],
        const SizedBox(height: AppSpacing.lg),
        const NoteBox.info(
          'A moderator checks each post before it goes public. '
          'Posts are anonymous.',
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.destinations, required this.selected});

  final List<Destination> destinations;
  final Destination? selected;

  @override
  Widget build(BuildContext context) {
    final d = selected;
    if (d == null) {
      final total = destinations.fold<int>(0, (sum, x) => sum + x.students);
      return Text(
        '$total students at ${destinations.length} schools',
        style: AppTextStyles.bodyStrong,
      );
    }
    return AppCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.school, style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${d.city} · ${d.students} students · ${d.distanceLabel}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final ExchangePost post;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${post.school} · ${post.term}',
            style: AppTextStyles.label.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(post.text, style: AppTextStyles.body),
          if (post.topics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [for (final t in post.topics) TagChip.topic(t)],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExchangeLoading extends StatelessWidget {
  const _ExchangeLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 220, radius: AppRadius.card),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(width: 180, height: 22),
        SizedBox(height: AppSpacing.xl),
        LoadingList(itemCount: 2, label: 'Loading the exchange forum'),
      ],
    );
  }
}
