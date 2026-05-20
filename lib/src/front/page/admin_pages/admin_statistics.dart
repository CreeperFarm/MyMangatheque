import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final AdminConnector _admin = AdminConnector();

  Future<Map<String, dynamic>> _loadData() async {
    final summary = await _admin.getSummary();
    final volumes = await _admin.getMostAddedVolumes();
    return <String, dynamic>{'summary': summary, 'volumes': volumes};
  }

  @override
  void initState() {
    super.initState();
    _admin.init();
  }

  @override
  Widget build(BuildContext context) {
    if (!_admin.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => pushOrGo(context, '/admin/admin_login'),
            child: const Text('Se connecter en admin'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data ?? <String, dynamic>{};
          final summary = data['summary'] as Map<String, dynamic>? ?? {};
          final summaryData =
              summary['data'] as Map<String, dynamic>? ?? const {};

          final mostAdded = data['volumes'] as Map<String, dynamic>? ?? {};
          final mostAddedData =
              mostAdded['data'] as Map<String, dynamic>? ?? const {};
          final topVolumes =
              mostAddedData['volumes'] as List<dynamic>? ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Résumé analytics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(summaryData.toString()),
              const SizedBox(height: 16),
              const Text(
                'Volumes les plus ajoutés',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (topVolumes.isEmpty)
                const Text('Aucune donnée')
              else
                ...topVolumes.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(item.toString()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
