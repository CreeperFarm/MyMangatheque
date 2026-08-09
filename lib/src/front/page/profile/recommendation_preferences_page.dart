import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';

class RecommendationPreferencesPage extends StatefulWidget {
  const RecommendationPreferencesPage({super.key, this.service});

  final RecommendationPreferencesService? service;

  @override
  State<RecommendationPreferencesPage> createState() =>
      _RecommendationPreferencesPageState();
}

class _RecommendationPreferencesPageState
    extends State<RecommendationPreferencesPage> {
  late final RecommendationPreferencesService _service =
      widget.service ?? RecommendationPreferencesService();
  RecommendationPreferences _preferences = const RecommendationPreferences();
  bool _loading = true;
  bool _saving = false;

  static const List<({String id, String en, String fr})> _genres = [
    (id: 'action', en: 'Action', fr: 'Action'),
    (id: 'adventure', en: 'Adventure', fr: 'Aventure'),
    (id: 'comedy', en: 'Comedy', fr: 'Comédie'),
    (id: 'drama', en: 'Drama', fr: 'Drame'),
    (id: 'fantasy', en: 'Fantasy', fr: 'Fantasy'),
    (id: 'historical', en: 'Historical', fr: 'Historique'),
    (id: 'horror', en: 'Horror', fr: 'Horreur'),
    (id: 'mystery', en: 'Mystery', fr: 'Mystère'),
    (id: 'romance', en: 'Romance', fr: 'Romance'),
    (id: 'science-fiction', en: 'Science fiction', fr: 'Science-fiction'),
    (id: 'slice-of-life', en: 'Slice of life', fr: 'Tranche de vie'),
    (id: 'sports', en: 'Sports', fr: 'Sport'),
    (id: 'thriller', en: 'Thriller', fr: 'Thriller'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await _service.loadPreferences();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.savePreferences(_preferences);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized(
              en: 'Recommendation preferences saved.',
              fr: 'Préférences de recommandation enregistrées.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localized(
            en: 'Recommendation preferences',
            fr: 'Préférences de recommandation',
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  context.localized(
                    en: 'What do you enjoy?',
                    fr: 'Qu’aimez-vous lire ?',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  context.localized(
                    en: 'These choices help new accounts. Your collection, reading history, wishlist and followed series progressively refine the ranking.',
                    fr: 'Ces choix aident les nouveaux comptes. Votre collection, vos lectures, vos envies et les séries suivies affinent ensuite progressivement le classement.',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genres.map((genre) {
                    final selected = _preferences.genres.contains(genre.id);
                    return FilterChip(
                      selected: selected,
                      label: Text(
                        context.localized(en: genre.en, fr: genre.fr),
                      ),
                      onSelected: (value) {
                        final genres = Set<String>.from(_preferences.genres);
                        value ? genres.add(genre.id) : genres.remove(genre.id);
                        setState(() {
                          _preferences = _preferences.copyWith(genres: genres);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.localized(
                      en: 'Prioritize recent releases',
                      fr: 'Prioriser les sorties récentes',
                    ),
                  ),
                  subtitle: Text(
                    context.localized(
                      en: 'Recent titles receive a small boost, never a hidden sponsored boost.',
                      fr: 'Les titres récents reçoivent un léger bonus, jamais un bonus sponsorisé caché.',
                    ),
                  ),
                  value: _preferences.preferNewReleases,
                  onChanged: (value) => setState(() {
                    _preferences = _preferences.copyWith(
                      preferNewReleases: value,
                    );
                  }),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.localized(
                      en: 'Diversify recommendations',
                      fr: 'Diversifier les recommandations',
                    ),
                  ),
                  subtitle: Text(
                    context.localized(
                      en: 'Reserve space for discoveries outside your usual genres.',
                      fr: 'Réserver une place aux découvertes hors de vos genres habituels.',
                    ),
                  ),
                  value: _preferences.diversify,
                  onChanged: (value) => setState(() {
                    _preferences = _preferences.copyWith(diversify: value);
                  }),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.localized(
                      en: 'Use popular choices when signals are insufficient',
                      fr: 'Utiliser les choix populaires si les signaux sont insuffisants',
                    ),
                  ),
                  value: _preferences.allowPopularFallback,
                  onChanged: (value) => setState(() {
                    _preferences = _preferences.copyWith(
                      allowPopularFallback: value,
                    );
                  }),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    context.localized(
                      en: 'Save preferences',
                      fr: 'Enregistrer',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.localized(
                    en: 'Sponsored placements remain clearly labelled and never alter the organic personalized score.',
                    fr: 'Les emplacements sponsorisés restent clairement étiquetés et ne modifient jamais le score personnalisé organique.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
