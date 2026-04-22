import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/storage_service.dart';
import '../widgets/shared_widgets.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> _books = [];
  static const _accent = Color(0xFF11998E);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final books = await StorageService.loadBooks();
    setState(() => _books = books);
  }

  Future<void> _save() => StorageService.saveBooks(_books);

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _showForm({Book? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final authorCtrl =
        TextEditingController(text: existing?.author ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookForm(
        formKey: formKey,
        nameCtrl: nameCtrl,
        authorCtrl: authorCtrl,
        isEdit: existing != null,
      ),
    );

    if (confirmed == true) {
      final book = Book(
        id: existing?.id ?? _uid(),
        name: nameCtrl.text.trim(),
        author: authorCtrl.text.trim(),
      );
      setState(() {
        if (existing != null) {
          final i = _books.indexWhere((b) => b.id == existing.id);
          if (i >= 0) _books[i] = book;
        } else {
          _books.add(book);
        }
      });
      await _save();
    }
  }

  Future<void> _delete(Book b) async {
    final ok = await confirmDelete(context, b.name);
    if (ok) {
      setState(() => _books.removeWhere((x) => x.id == b.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
      ),
      body: _books.isEmpty
          ? const EmptyState(
              icon: Icons.menu_book_rounded,
              message: 'No books yet. Add your first!')
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: _books.length,
              itemBuilder: (_, i) => ItemTile(
                title: _books[i].name,
                subtitle: _books[i].author.isNotEmpty
                    ? _books[i].author
                    : null,
                accentColor: _accent,
                onEdit: () => _showForm(existing: _books[i]),
                onDelete: () => _delete(_books[i]),
              ),
            ),
    );
  }
}

class _BookForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController authorCtrl;
  final bool isEdit;

  const _BookForm({
    required this.formKey,
    required this.nameCtrl,
    required this.authorCtrl,
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
              Text(isEdit ? 'Edit Book' : 'Add Book',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g. 1984',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(14))),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: authorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Author (optional)',
                  hintText: 'e.g. George Orwell',
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
                    backgroundColor: const Color(0xFF11998E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    isEdit ? 'Save Changes' : 'Add Book',
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