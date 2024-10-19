import 'package:flutter/material.dart';
import 'package:mymangatheque/src/services/pocketbase.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer mon compte'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Êtes-vous sûr de vouloir supprimer votre compte ?'),
            const Text('Cette action est irréversible.'),
            ElevatedButton(
              onPressed: PocketBaseConnector().deleteUser(PocketBaseConnector().getConnectedUser()!.id),
              child: const Text('Supprimer mon compte'),
            ),
          ],
        ),
      ),
    );
  }
}
