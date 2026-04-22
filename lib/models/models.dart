import 'dart:convert';

// ─── Game ───────────────────────────────────────────────────────────────────
class Game {
  final String id;
  final String name;
  final String studio;

  Game({required this.id, required this.name, this.studio = ''});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'studio': studio};

  factory Game.fromMap(Map<String, dynamic> m) =>
      Game(id: m['id'], name: m['name'], studio: m['studio'] ?? '');

  String toJson() => jsonEncode(toMap());
  factory Game.fromJson(String s) => Game.fromMap(jsonDecode(s));
}

// ─── Film ───────────────────────────────────────────────────────────────────
class Film {
  final String id;
  final String name;
  final String director;

  Film({required this.id, required this.name, this.director = ''});

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'director': director};

  factory Film.fromMap(Map<String, dynamic> m) =>
      Film(id: m['id'], name: m['name'], director: m['director'] ?? '');

  String toJson() => jsonEncode(toMap());
  factory Film.fromJson(String s) => Film.fromMap(jsonDecode(s));
}

// ─── Book ───────────────────────────────────────────────────────────────────
class Book {
  final String id;
  final String name;
  final String author;

  Book({required this.id, required this.name, this.author = ''});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'author': author};

  factory Book.fromMap(Map<String, dynamic> m) =>
      Book(id: m['id'], name: m['name'], author: m['author'] ?? '');

  String toJson() => jsonEncode(toMap());
  factory Book.fromJson(String s) => Book.fromMap(jsonDecode(s));
}

// ─── Secret ─────────────────────────────────────────────────────────────────
class Secret {
  final String id;
  final String resource;
  final String password;

  Secret({required this.id, required this.resource, required this.password});

  Map<String, dynamic> toMap() =>
      {'id': id, 'resource': resource, 'password': password};

  factory Secret.fromMap(Map<String, dynamic> m) =>
      Secret(id: m['id'], resource: m['resource'], password: m['password']);

  String toJson() => jsonEncode(toMap());
  factory Secret.fromJson(String s) => Secret.fromMap(jsonDecode(s));
}