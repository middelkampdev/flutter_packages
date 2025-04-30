import 'package:elevator/elevator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elevator Example',
      theme: ThemeData(shadowColor: Colors.black.withValues(alpha: .05)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elevator Example')),
      body: Center(
        child: SizedBox(
          width: 600,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 20,
            itemBuilder: (context, index) {
              return CardListItem(index: index);
            },
          ),
        ),
      ),
    );
  }
}

class CardListItem extends StatelessWidget {
  const CardListItem({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Elevator(
        builder: (elevated) {
          return GestureDetector(
            onTap: () async {
              return showDialog<void>(
                context: context,
                builder: (context) {
                  return const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Hello'),
                    ),
                  );
                },
              );
            },
            child: Card(
              margin: EdgeInsets.zero,
              elevation: elevated ? 12 : 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Text(
                  'Item $index',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
