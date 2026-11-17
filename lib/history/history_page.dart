import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/app_loader.dart';
import '../data/firestore_repository.dart';
import '../game/domain/level.dart';
import '../game/ui/l10n_helpers.dart';
import '../l10n/app_localizations.dart';

/// Histórico do jogador, lido do Firestore com FutureBuilder.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late Future<UserStats> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<UserStats> _load() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return ref.read(firestoreRepositoryProvider).stats(uid);
  }

  Future<void> _refresh() async {
    final f = _load();
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(tooltip: l10n.retry, onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<UserStats>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoader();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorRetry(message: l10n.loadError, retryLabel: l10n.retry, onRetry: _refresh);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _HistoryContent(stats: snapshot.data!),
          );
        },
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.stats});
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1000 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MaxWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, size: 48, color: scheme.onPrimaryContainer),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.totalScore,
                                  style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
                              Text('${stats.score}',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w800,
                                  )),
                              Text(l10n.solvedCount(stats.totalSolved),
                                  style: TextStyle(color: scheme.onPrimaryContainer)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.solvedByLevel, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final level in Level.values)
                      Chip(
                        avatar: CircleAvatar(child: Text('${stats.solvedByLevel[level] ?? 0}')),
                        label: Text(l10n.levelName(level)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.recentSolved, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (stats.recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.noSolvedYet, textAlign: TextAlign.center),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.recent.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 128,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, i) => _SolvedCard(entry: stats.recent[i]),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SolvedCard extends StatelessWidget {
  const _SolvedCard({required this.entry});
  final SolvedEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2EE),
                    border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.number.toString().padLeft(4, '0'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFF151515),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.solvedIn(l10n.levelName(entry.level), entry.seconds),
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                entry.latex,
                textStyle: TextStyle(fontSize: 20, color: theme.colorScheme.onSurface),
                onErrorFallback: (e) => Text(entry.expression),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
