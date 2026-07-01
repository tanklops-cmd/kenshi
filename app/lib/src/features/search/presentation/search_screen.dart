import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/search/application/search_providers.dart';
import 'package:kendo_companion/src/features/search/domain/search_result.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _debounceDuration = Duration(milliseconds: 300);

  Timer? _debounce;
  List<SearchResult> _results = const [];
  String _query = '';
  bool _loading = false;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _queryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    setState(() {
      _query = query;
      _results = const [];
      _loading = false;
    });
    if (query.length < 2) {
      return;
    }
    _debounce = Timer(_debounceDuration, () => unawaited(_search(query)));
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    if (mounted) {
      setState(() => _loading = true);
    }
    try {
      final results = await ref.read(searchServiceProvider).search(query);
      if (mounted && requestId == _requestId && query == _query) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } on Object {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              key: const ValueKey('searchField'),
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search your kendo learning',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _queryChanged,
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.length < 2) {
      return const SizedBox.shrink();
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    final groups = SearchResultType.values
        .map(
          (type) => MapEntry(
            type,
            _results.where((result) => result.type == type).toList(),
          ),
        )
        .where((entry) => entry.value.isNotEmpty)
        .toList(growable: false);

    return ListView.builder(
      key: const ValueKey('searchResultsList'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _ResultGroup(type: group.key, results: group.value);
      },
    );
  }
}

class _ResultGroup extends StatelessWidget {
  const _ResultGroup({required this.type, required this.results});

  final SearchResultType type;
  final List<SearchResult> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
          child: Text(
            type.groupLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final result in results)
          Card(
            child: ListTile(
              onTap: () => _openResult(context, result),
              title: Text(result.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.typeLabel),
                  Text(
                    result.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              trailing: result.date == null
                  ? const Icon(Icons.chevron_right)
                  : Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(result.date!.toLocal()),
                    ),
            ),
          ),
      ],
    );
  }

  void _openResult(BuildContext context, SearchResult result) {
    final location = switch (result.type) {
      SearchResultType.session => AppRoutes.sessionDetailLocation(result.id),
      SearchResultType.practice => AppRoutes.practiceTopicDetailLocation(
        result.id,
      ),
      SearchResultType.learn => AppRoutes.learnTopicDetailLocation(result.id),
      SearchResultType.moment => AppRoutes.momentDetailLocation(
        sessionId: result.parentId!,
        momentId: result.id,
      ),
    };
    context.push(location);
  }
}
