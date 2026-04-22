import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/storage_service.dart';
import '../widgets/shared_widgets.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List<Game> _games = [];
  static const _accent = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final games = await StorageService.loadGames();
    setState(() => _games = games);
  }

  Future<void> _save() => StorageService.saveGames(_games);

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _showForm({Game? existing}) async {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final studioCtrl =
        TextEditingController(text: existing?.studio ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GameForm(
        formKey: formKey,
        nameCtrl: nameCtrl,
        studioCtrl: studioCtrl,
        isEdit: existing != null,
      ),
    );

    if (confirmed == true) {
      final game = Game(
        id: existing?.id ?? _uid(),
        name: nameCtrl.text.trim(),
        studio: studioCtrl.text.trim(),
      );
      setState(() {
        if (existing != null) {
          final i = _games.indexWhere((g) => g.id == existing.id);
          if (i >= 0) _games[i] = game;
        } else {
          _games.add(game);
        }
      });
      await _save();
    }
  }

  Future<void> _delete(Game g) async {
    final ok = await confirmDelete(context, g.name);
    if (ok) {
      setState(() => _games.removeWhere((x) => x.id == g.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Game'),
      ),
      body: _games.isEmpty
          ? const EmptyState(
              icon: Icons.sports_esports_rounded,
              message: 'No games yet. Add your first!')
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: _games.length,
              itemBuilder: (_, i) => ItemTile(
                title: _games[i].name,
                subtitle: _games[i].studio.isNotEmpty
                    ? _games[i].studio
                    : null,
                accentColor: _accent,
                onEdit: () => _showForm(existing: _games[i]),
                onDelete: () => _delete(_games[i]),
              ),
            ),
    );
  }
}

class _GameForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController studioCtrl;
  final bool isEdit;

  const _GameForm({
    required this.formKey,
    required this.nameCtrl,
    required this.studioCtrl,
    required this.isEdit,
  });

  @override
  State<_GameForm> createState() => _GameFormState();
}

class _GameFormState extends State<_GameForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: widget.formKey,
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isEdit ? 'Edit Game' : 'Add Game',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: widget.nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g. The Witcher 3',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(14))),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: widget.studioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Studio (optional)',
                  hintText: 'e.g. CD Projekt Red',
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
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    widget.isEdit ? 'Save Changes' : 'Add Game',
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