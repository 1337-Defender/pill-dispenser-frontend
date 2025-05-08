// lib/screens/history/dispensing_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/history_provider.dart';

class DispensingHistoryScreen extends StatelessWidget {
  const DispensingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispensing History"),
        centerTitle: true,
      ),
      body: historyProvider.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No dispensing history yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: historyProvider.history.length,
              itemBuilder: (context, index) {
                final item = historyProvider.history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(item.medicationName),
                    subtitle: Text("${item.quantityDispensed} pills at ${item.dispensedAt}"),
                    trailing: Text(
                      item.dispensedAt.toLocal().toString().split(' ')[0],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}