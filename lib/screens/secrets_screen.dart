import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../models/storage_service.dart';
import '../widgets/shared_widgets.dart';

class SecretsScreen extends StatefulWidget {
  const SecretsScreen({super.key});

  @override
  State<SecretsScreen> createState() => _SecretsScreenState();
}

class _SecretsScreenState extends State<SecretsScreen> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    return _unlocked
        ? _SecretsListScreen(onLock: () => setState(() => _unlocked = false))
        : _PinScreen(onUnlocked: () => setState(() => _unlocked = true));
  }
}

// ─── PIN / Password gate ─────────────────────────────────────────────────────
class _PinScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const _PinScreen({required this.onUnlocked});

  @override
  State<_PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<_PinScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  bool _shake = false;
  String? _error;
  late AnimationController _anim;
  late Animation<double> _shakeAnim;

  static const _correctPassword = 'mvs2001';
  static const _accent = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_anim);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text == _correctPassword) {
      widget.onUnlocked();
    } else {
      setState(() => _error = 'Incorrect password');
      _anim.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secrets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: AnimatedBuilder(
            animation: _shakeAnim,
            builder: (ctx, child) => Transform.translate(
              offset: Offset(_anim.isAnimating ? _shakeAnim.value : 0, 0),
              child: child,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2C3E50).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Protected Area',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your password to continue',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _ctrl,
                  obscureText: _obscure,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _error,
                    border: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(14))),
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submit,
                    child: const Text('Unlock',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Secrets list ─────────────────────────────────────────────────────────────
class _SecretsListScreen extends StatefulWidget {
  final VoidCallback onLock;
  const _SecretsListScreen({required this.onLock});

  @override
  State<_SecretsListScreen> createState() => _SecretsListScreenState();
}

class _SecretsListScreenState extends State<_SecretsListScreen> {
  List<Secret> _secrets = [];
  static const _accent = Color(0xFF4CA1AF);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await StorageService.loadSecrets();
    setState(() => _secrets = s);
  }

  Future<void> _save() => StorageService.saveSecrets(_secrets);

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _showForm({Secret? existing}) async {
    final resCtrl =
        TextEditingController(text: existing?.resource ?? '');
    final passCtrl =
        TextEditingController(text: existing?.password ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SecretForm(
        formKey: formKey,
        resCtrl: resCtrl,
        passCtrl: passCtrl,
        isEdit: existing != null,
      ),
    );

    if (confirmed == true) {
      final secret = Secret(
        id: existing?.id ?? _uid(),
        resource: resCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      setState(() {
        if (existing != null) {
          final i =
              _secrets.indexWhere((s) => s.id == existing.id);
          if (i >= 0) _secrets[i] = secret;
        } else {
          _secrets.add(secret);
        }
      });
      await _save();
    }
  }

  Future<void> _delete(Secret s) async {
    final ok = await confirmDelete(context, s.resource);
    if (ok) {
      setState(() => _secrets.removeWhere((x) => x.id == s.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secrets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Lock',
            icon: const Icon(Icons.lock_open_rounded),
            onPressed: widget.onLock,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Secret'),
      ),
      body: _secrets.isEmpty
          ? const EmptyState(
              icon: Icons.shield_rounded,
              message: 'No secrets yet. Add your first!')
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: _secrets.length,
              itemBuilder: (_, i) => _SecretTile(
                secret: _secrets[i],
                onEdit: () => _showForm(existing: _secrets[i]),
                onDelete: () => _delete(_secrets[i]),
              ),
            ),
    );
  }
}

class _SecretTile extends StatefulWidget {
  final Secret secret;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SecretTile({
    required this.secret,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SecretTile> createState() => _SecretTileState();
}

class _SecretTileState extends State<_SecretTile> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4CA1AF);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shield_rounded, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.secret.resource,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _visible
                            ? widget.secret.password
                            : '•' * widget.secret.password.length.clamp(6, 16),
                        style: TextStyle(
                          fontFamily: _visible ? null : 'monospace',
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55),
                          fontSize: 13,
                          letterSpacing: _visible ? 0 : 2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _visible = !_visible),
                        child: Icon(
                          _visible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 16,
                          color: accent.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy_rounded,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4)),
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: widget.secret.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password copied!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.edit_rounded,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4)),
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded,
                  size: 18, color: Color(0xFFFF6B6B)),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecretForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController resCtrl;
  final TextEditingController passCtrl;
  final bool isEdit;

  const _SecretForm({
    required this.formKey,
    required this.resCtrl,
    required this.passCtrl,
    required this.isEdit,
  });

  @override
  State<_SecretForm> createState() => _SecretFormState();
}

class _SecretFormState extends State<_SecretForm> {
  bool _obscure = true;

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
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(widget.isEdit ? 'Edit Secret' : 'Add Secret',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: widget.resCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Resource *',
                  hintText: 'e.g. Gmail, GitHub',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(14))),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Resource is required'
                        : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: widget.passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Enter the password',
                  border: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(14))),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Password is required'
                        : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4CA1AF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    widget.isEdit ? 'Save Changes' : 'Add Secret',
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