import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/moment/presentation/moment_thumbnail.dart';
import 'package:kendo_companion/src/features/search/presentation/search_button.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:kendo_companion/src/features/today/application/today_providers.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  // Transient checklist — resets each time Today is visited.
  final Set<int> _checkedIndices = {};

  void _toggleCheck(int index) {
    setState(() {
      if (_checkedIndices.contains(index)) {
        _checkedIndices.remove(index);
      } else {
        _checkedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final focusItems = ref.watch(currentFocusItemsProvider);
    final lastReview = ref.watch(lastReviewSessionProvider);
    final recentGuidance = ref.watch(recentGuidanceProvider);
    final recentMoment = ref.watch(recentMomentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: const [SearchButton()],
      ),
      body: sessions.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        error: (_, _) => _ErrorState(
          onRetry: () => ref.invalidate(sessionsProvider),
        ),
        data: (_) => _DashboardBody(
          focusItems: focusItems,
          checkedIndices: _checkedIndices,
          onToggleCheck: _toggleCheck,
          lastReview: lastReview,
          recentGuidance: recentGuidance,
          recentMoment: recentMoment,
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.focusItems,
    required this.checkedIndices,
    required this.onToggleCheck,
    required this.lastReview,
    required this.recentGuidance,
    required this.recentMoment,
  });

  final List<String> focusItems;
  final Set<int> checkedIndices;
  final ValueChanged<int> onToggleCheck;
  final Session? lastReview;
  final AsyncValue<List<GuidanceEntry>> recentGuidance;
  final AsyncValue<Moment?> recentMoment;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('todayDashboard'),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
      children: [
        _CurrentFocusSection(
          items: focusItems,
          checkedIndices: checkedIndices,
          onToggle: onToggleCheck,
        ),
        const SizedBox(height: 32),
        _RecentGuidanceSection(guidance: recentGuidance),
        const SizedBox(height: 32),
        _RecentMomentSection(moment: recentMoment),
        const SizedBox(height: 32),
        _LastReviewSection(session: lastReview),
        const SizedBox(height: 32),
        const _QuickActionsSection(),
      ],
    );
  }
}

// ─── Section Heading ──────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
    );
  }
}

// ─── Current Focus ────────────────────────────────────────────────────────────

class _CurrentFocusSection extends StatelessWidget {
  const _CurrentFocusSection({
    required this.items,
    required this.checkedIndices,
    required this.onToggle,
  });

  final List<String> items;
  final Set<int> checkedIndices;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Current Focus'),
        const SizedBox(height: 14),
        if (items.isEmpty)
          _FocusEmptyState()
        else
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _FocusCheckItem(
              key: ValueKey('focusItem_$i'),
              text: items[i],
              checked: checkedIndices.contains(i),
              onTap: () => onToggle(i),
            ),
          ],
      ],
    );
  }
}

class _FocusCheckItem extends StatelessWidget {
  const _FocusCheckItem({
    required this.text,
    required this.checked,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                checked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(checked),
                size: 22,
                color: checked
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: checked
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  decorationColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Add a Next Focus to a session to see it here.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

// ─── Recent Guidance ─────────────────────────────────────────────────────────

class _RecentGuidanceSection extends StatelessWidget {
  const _RecentGuidanceSection({required this.guidance});

  final AsyncValue<List<GuidanceEntry>> guidance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Recent Guidance'),
        const SizedBox(height: 14),
        guidance.when(
          loading: () => _SectionLoadingIndicator(),
          error: (_, _) => _SectionLoadingIndicator(),
          data: (entries) => entries.isEmpty
              ? _GuidanceEmptyState()
              : Column(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _GuidanceCard(
                        key: ValueKey('guidanceCard_${entries[i].id}'),
                        entry: entries[i],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.entry, super.key});

  final GuidanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.sessionDetailLocation(entry.sessionId),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.coachName case final name?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    name,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              Text(
                entry.advice,
                style: textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidanceEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Guidance from your sessions will appear here.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

// ─── Recent Moment ────────────────────────────────────────────────────────────

class _RecentMomentSection extends StatelessWidget {
  const _RecentMomentSection({required this.moment});

  final AsyncValue<Moment?> moment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Recent Moment'),
        const SizedBox(height: 14),
        moment.when(
          loading: () => _SectionLoadingIndicator(),
          error: (_, _) => _SectionError(),
          data: (value) =>
              value == null ? _MomentEmptyState() : _MomentCard(moment: value),
        ),
      ],
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const ValueKey('recentMomentCard'),
        onTap: () => context.push(
          AppRoutes.momentDetailLocation(
            sessionId: moment.sessionId,
            momentId: moment.id,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MomentThumbnail(moment: moment, height: 160),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                moment.title.trim().isEmpty ? moment.type.label : moment.title,
                style: textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Your most memorable training moment will appear here.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

// ─── Last Review ─────────────────────────────────────────────────────────────

class _LastReviewSection extends StatelessWidget {
  const _LastReviewSection({required this.session});

  final Session? session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Last Review'),
        const SizedBox(height: 14),
        session == null ? _ReviewEmptyState() : _ReviewCard(session: session!),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    final notes = _previewNotes(session);
    final date = localizations.formatMediumDate(session.trainingDate);

    return Card(
      child: InkWell(
        key: const ValueKey('lastReviewCard'),
        onTap: () =>
            context.push(AppRoutes.sessionDetailLocation(session.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(session.title, style: textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Text(date, style: textTheme.bodySmall),
              if (notes != null) ...[
                const SizedBox(height: 10),
                Text(
                  notes,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _previewNotes(Session s) {
    if (s.reviewNotes?.trim().isNotEmpty == true) return s.reviewNotes!.trim();
    if (s.freshNotes?.trim().isNotEmpty == true) return s.freshNotes!.trim();
    return null;
  }
}

class _ReviewEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Your last session review will appear here.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Quick Actions'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ActionButton(
              key: const ValueKey('quickNewSession'),
              icon: Icons.add,
              label: 'New Session',
              onPressed: () => context.push(AppRoutes.newSession),
            ),
            _ActionButton(
              key: const ValueKey('quickPractice'),
              icon: Icons.fitness_center_outlined,
              label: 'Practice',
              onPressed: () => context.go(AppRoutes.practice),
            ),
            _ActionButton(
              key: const ValueKey('quickSearch'),
              icon: Icons.search,
              label: 'Search',
              onPressed: () => context.push(AppRoutes.search),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

// ─── Shared States ────────────────────────────────────────────────────────────

class _SectionLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SectionError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Could not load.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dashboard could not be loaded.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

