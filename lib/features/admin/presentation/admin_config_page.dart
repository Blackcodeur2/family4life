import 'package:flutter/material.dart';

class AdminConfigPage extends StatelessWidget {
  const AdminConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fixedAmountController = TextEditingController();
    final minPointsController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: fixedAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant fixe de contribution',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: minPointsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum de points requis',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: sauvegarder ces paramètres dans une table de configuration Supabase
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
