import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import 'common.dart';

enum TextSectionsKind { howToPlay, privacy }

/// A readable page of titled paragraphs: How to play, Privacy and terms.
class TextSectionsScreen extends StatelessWidget {
  const TextSectionsScreen({super.key, required this.kind});

  final TextSectionsKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final theme = Theme.of(context);
    final title = kind == TextSectionsKind.howToPlay
        ? l10n.howToPlay
        : l10n.privacyAndTerms;
    final sections = kind == TextSectionsKind.howToPlay
        ? l10n.rulesSections
        : l10n.privacySections;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: <Widget>[
              for (final (heading, body) in sections) ...<Widget>[
                const SizedBox(height: 16),
                Text(heading, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(body, style: theme.textTheme.bodyLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
