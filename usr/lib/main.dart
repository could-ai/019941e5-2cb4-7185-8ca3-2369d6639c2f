import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frankenstein\'s Elixir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1a1a1a),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2c2c2c),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2c2c2c),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[400]),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
        ),
      ),
      home: const FrankensteinHomePage(),
    );
  }
}

class FrankensteinHomePage extends StatefulWidget {
  const FrankensteinHomePage({super.key});

  @override
  State<FrankensteinHomePage> createState() => _FrankensteinHomePageState();
}

class _FrankensteinHomePageState extends State<FrankensteinHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  final Map<String, List<List<String>>> _recipes = {};
  final Map<String, int> _memo = {};

  @override
  void initState() {
    super.initState();
    _controller.text = '''4
awakening=snakefangs+wolfbane
veritaserum=snakefangs+awakening
dragontonic=snakefangs+velarin
dragontonic=awakening+veritaserum
dragontonic''';
  }

  void _calculateMinimumOrbs() {
    _recipes.clear();
    _memo.clear();

    final lines = _controller.text.trim().split('\n').where((l) => l.isNotEmpty).toList();
    if (lines.length < 2) {
      setState(() {
        _result = 'Invalid input. Please provide recipes and a target potion.';
      });
      return;
    }

    final targetPotion = lines.removeLast();
    // The first line is N, we can ignore it and just process the recipe lines
    final recipeLines = lines.sublist(1);

    for (final line in recipeLines) {
      final parts = line.split('=');
      if (parts.length != 2) continue;
      final potion = parts[0].trim();
      final ingredients = parts[1].split('+').map((i) => i.trim()).toList();
      _recipes.putIfAbsent(potion, () => []).add(ingredients);
    }

    final minOrbs = _getMinOrbs(targetPotion);

    setState(() {
      if (minOrbs >= 999999) {
         _result = 'It is impossible to brew "$targetPotion" with the given recipes.';
      } else {
         _result = 'Minimum orbs to brew "$targetPotion": $minOrbs';
      }
    });
  }

  int _getMinOrbs(String potion) {
    if (_memo.containsKey(potion)) {
      return _memo[potion]!;
    }

    if (!_recipes.containsKey(potion)) {
      // It's a base ingredient, cost is 0
      return _memo.putIfAbsent(potion, () => 0);
    }

    int minPotionCost = 999999; // Represents infinity

    for (final recipe in _recipes[potion]!) {
      int currentRecipeCost = recipe.length - 1;
      for (final ingredient in recipe) {
        currentRecipeCost += _getMinOrbs(ingredient);
      }
      minPotionCost = min(minPotionCost, currentRecipeCost);
    }

    return _memo.putIfAbsent(potion, () => minPotionCost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frankenstein's Elixir Calculator"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter the recipes and the target potion below:',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 10,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  hintText: 'e.g.,\n4\nrecipe1=ing1+ing2\n...\ntarget_potion',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateMinimumOrbs,
                child: const Text('Calculate Minimum Orbs'),
              ),
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2c2c2c),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
