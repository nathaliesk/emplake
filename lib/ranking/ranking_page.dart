import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/app_loader.dart';
import '../data/firestore_repository.dart';
import '../l10n/app_localizations.dart';

/// Ranking geral (top 20), lido do Firestore com FutureBuilder.
class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> {
  late Future<List<RankingEntry>> _future = ref.read(firestoreRepositoryProvider).ranking();

  Future<void> _refresh() async {
    final f = ref.read(firestoreRepositoryProvider).ranking();
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = FirebaseAuth.instance.currentUser?.uid;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rankingTitle),
        actions: [IconButton(tooltip: l10n.retry, onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      body: FutureBuilder<List<RankingEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const AppLoader();
          if (snapshot.hasError) {
            return ErrorRetry(message: l10n.loadError, retryLabel: l10n.retry, onRetry: _refresh);
          }
          final list = snapshot.data ?? const [];
          if (list.isEmpty) {
            return Center(child: Text(l10n.rankingEmpty, textAlign: TextAlign.center));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final e = list[i];
                final isMe = e.uid == me;
                final medal = switch (i) {
                  0 => const Color(0xFFFFC107),
                  1 => const Color(0xFFB0BEC5),
                  2 => const Color(0xFFCD7F32),
                  _ => scheme.surfaceContainerHighest,
                };
                return MaxWidth(
                  maxWidth: 720,
                  child: Card(
                    color: isMe ? scheme.secondaryContainer : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: medal,
                        foregroundColor: i < 3 ? Colors.black : scheme.onSurface,
                        child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      title: Text(
                        e.name.isEmpty ? l10n.anonymousPlayer : e.name,
                        style: TextStyle(fontWeight: isMe ? FontWeight.w800 : FontWeight.w500),
                      ),
                      subtitle: isMe ? Text(l10n.you) : null,
                      trailing: Text(l10n.points(e.score), style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
