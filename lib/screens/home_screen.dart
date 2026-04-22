import 'package:flutter/material.dart';
import 'games_screen.dart';
import 'films_screen.dart';
import 'books_screen.dart';
import 'secrets_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _TileData(
        label: 'Games',
        icon: Icons.sports_esports_rounded,
        gradient: [const Color(0xFF6C63FF), const Color(0xFF9C88FF)],
        screen: const GamesScreen(),
      ),
      _TileData(
        label: 'Films',
        icon: Icons.movie_rounded,
        gradient: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
        screen: const FilmsScreen(),
      ),
      _TileData(
        label: 'Books',
        icon: Icons.menu_book_rounded,
        gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
        screen: const BooksScreen(),
      ),
      _TileData(
        label: 'Secrets',
        icon: Icons.lock_rounded,
        gradient: [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
        screen: const SecretsScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'My Vault',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your personal collection',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: tiles
                      .map((t) => _VaultTile(data: t))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileData {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Widget screen;

  const _TileData({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.screen,
  });
}

class _VaultTile extends StatelessWidget {
  final _TileData data;
  const _VaultTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => data.screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration circle
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 28),
                  ),
                  Text(
                    data.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}