import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  static const _gamesKey = 'games';
  static const _filmsKey = 'films';
  static const _booksKey = 'books';
  static const _secretsKey = 'secrets';

  // ─── Games ──────────────────────────────────────────────────────────────
  static Future<List<Game>> loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_gamesKey) ?? [];
    return list.map((s) => Game.fromJson(s)).toList();
  }

  static Future<void> saveGames(List<Game> games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_gamesKey, games.map((g) => g.toJson()).toList());
  }

  // ─── Films ──────────────────────────────────────────────────────────────
  static Future<List<Film>> loadFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_filmsKey) ?? [];
    return list.map((s) => Film.fromJson(s)).toList();
  }

  static Future<void> saveFilms(List<Film> films) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_filmsKey, films.map((f) => f.toJson()).toList());
  }

  // ─── Books ──────────────────────────────────────────────────────────────
  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_booksKey) ?? [];
    return list.map((s) => Book.fromJson(s)).toList();
  }

  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_booksKey, books.map((b) => b.toJson()).toList());
  }

  // ─── Secrets ────────────────────────────────────────────────────────────
  static Future<List<Secret>> loadSecrets() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_secretsKey) ?? [];
    return list.map((s) => Secret.fromJson(s)).toList();
  }

  static Future<void> saveSecrets(List<Secret> secrets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _secretsKey, secrets.map((s) => s.toJson()).toList());
  }
}