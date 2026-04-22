import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/storage_service.dart';
import '../widgets/shared_widgets.dart';

class FilmsScreen extends StatefulWidget {
  const FilmsScreen({super.key});

  @override
  State<FilmsScreen> createState() => _FilmsScreenState();
}

class _FilmsScreenState extends State<FilmsScreen> {
  List<Film> _films = [];
  static const _accent = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final films = await StorageService.loadFilms();
    setState(() => _films = films);
  }

  Future<void> _save() => StorageService.saveFilms(_films);

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _showForm({Film? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final dirCtrl =
        TextEditingController(text: existing?.director ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FilmForm(
        formKey: formKey,
        nameCtrl: nameCtrl,
        dirCtrl: dirCtrl,
        isEdit: existing != null,
      ),
    );

    if (confirmed == true) {
      final film = Film(
        id: existing?.id ?? _uid(),
        name: nameCtrl.text.trim(),
        director: dirCtrl.text.trim(),
      );
      setState(() {
        if (existing != null) {
          final i = _films.indexWhere((f) => f.id == existing.id);
          if (i >= 0) _films[i] = film;
        } else {
          _films.add(film);
        }
      });
      await _save();
    }
  }

  Future<void> _delete(Film f) async {
    final ok = await confirmDelete(context, f.name);
    if (ok) {
      setState(() => _films.removeWhere((x) => x.id == f.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Film'),
      ),
      body: _films.isEmpty
          ? const EmptyState(
              icon: Icons.movie_rounded,
              message: 'No films yet. Add your first!')
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: _films.length,
              itemBuilder: (_, i) => ItemTile(
                title: _films[i].name,
                subtitle: _films[i].director.isNotEmpty
                    ? _films[i].director
                    : null,
                accentColor: _accent,
                onEdit: () => _showForm(existing: _films[i]),
                onDelete: () => _delete(_films[i]),
              ),
            ),
    );
  }
}

class _FilmForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController dirCtrl;
  final bool isEdit;

  const _FilmForm({
    required this.formKey,
    required this.nameCtrl,
    required this.dirCtrl,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(isEdit ? 'Edit Film' : 'Add Film',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g. Inception',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(14))),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: dirCtrl,
                decoration: const InputDecoration(
                  labelText: 'Director (optional)',
                  hintText: 'e.g. Christopher Nolan',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(14))),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    isEdit ? 'Save Changes' : 'Add Film',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}