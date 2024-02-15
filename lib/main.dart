// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadMainScreen();
  }

  _loadMainScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GridSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_launcher.png',
              height: 50,
            ),
            const Text(
              'Splash Screen',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class GridSearchScreen extends StatefulWidget {
  const GridSearchScreen({super.key});

  @override
  _GridSearchScreenState createState() => _GridSearchScreenState();
}

class _GridSearchScreenState extends State<GridSearchScreen> {
  int m = 0;
  int n = 0;
  List<List<String>> grid = [];
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grid Search',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Enter grid dimensions:'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          m = int.tryParse(value) ?? 0;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Rows (m)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          n = int.tryParse(value) ?? 0;
                        });
                      },
                      decoration:
                          const InputDecoration(labelText: 'Columns (n)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  _createGrid();
                },
                child: const Text(
                  'Create Grid',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (grid.isNotEmpty) ...[
                const Text('Grid:'),
                _buildGrid(),
                const SizedBox(height: 16),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  validator: (value) {
                    final regex =
                        RegExp(r'^[a-zA-Z]+$'); // Allows one or more letters
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Only letters (a-z, A-Z) are allowed.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search Word',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _searchText();
                  },
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _resetSetup();
                  },
                  child: const Text(
                    'Reset Setup',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Column(
        children: List.generate(
          m,
          (row) => Row(
            children: List.generate(
              n,
              (col) => Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Text(grid[row][col]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _searchInDirection(
      int startRow, int startCol, int rowIncrement, int colIncrement) {
    for (int row = startRow, col = startCol, idx = 0;
        idx < searchText.length;
        idx++, row += rowIncrement, col += colIncrement) {
      // Check bounds
      if (row < 0 || row >= m || col < 0 || col >= n) return false;
      // Check character match
      if (grid[row][col].toUpperCase() != searchText[idx].toUpperCase())
        return false;
    }
    // If complete word is matched
    _highlightText(
        startRow, startCol, rowIncrement, colIncrement, searchText.length);
    return true;
  }

  void _createGrid() {
    // Check if both m and n are greater than 0
    if (m > 0 && n > 0) {
      // Generate grid with random alphabets for simplicity
      grid = List.generate(
        m,
        (row) => List.generate(
          n,
          (col) => String.fromCharCode('A'.codeUnitAt(0) + row * n + col),
        ),
      );
      setState(() {});
    }
  }

  void _searchText() {
    bool found = false;
    for (int row = 0; row < m && !found; row++) {
      for (int col = 0; col < n && !found; col++) {
        // Right (0, 1), Down (1, 0), Diagonal down-right (1, 1)
        found = _searchInDirection(row, col, 0, 1) ||
            _searchInDirection(row, col, 1, 0) ||
            _searchInDirection(row, col, 1, 1);
      }
    }
    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Word not found in the grid'),
      ));
    }
  }

  void _highlightText(int startRow, int startCol, int rowIncrement,
      int colIncrement, int length) {
    for (int i = 0; i < length; i++) {
      int row = startRow + i * rowIncrement;
      int col = startCol + i * colIncrement;
      setState(() {
        grid[row][col] = '*${grid[row][col]}*'; // Example way to highlight
      });
    }
  }

  void _resetSetup() {
    setState(() {
      m = 0;
      n = 0;
      grid = [];
      searchText = '';
    });
  }
}
