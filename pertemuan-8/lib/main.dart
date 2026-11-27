import 'package:flutter/material.dart';

import 'models/admin.dart';
import 'models/user.dart';
import 'services/admin_service.dart';
import 'services/api_service.dart';

const userIdFromNim = 1524;
const adminIdFromNim = 817;

void main() => runApp(const PraktikumApp());

class PraktikumApp extends StatelessWidget {
  final ApiService? apiService;
  final AdminService? adminService;

  const PraktikumApp({super.key, this.apiService, this.adminService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User dan Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: DashboardPage(apiService: apiService, adminService: adminService),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final ApiService? apiService;
  final AdminService? adminService;

  const DashboardPage({super.key, this.apiService, this.adminService});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ApiService _apiService = widget.apiService ?? ApiService();
  late final AdminService _adminService = widget.adminService ?? AdminService();
  int _tabIndex = 0;
  Future<List<User>>? _usersFuture;
  Future<List<Admin>>? _adminsFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadAdmins();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _apiService.getUsers();
    });
  }

  void _loadAdmins() {
    setState(() {
      _adminsFuture = _adminService.getAdmins();
    });
  }

  Future<void> _showUserById() async {
    final id = await _askForId('Detail User', userIdFromNim);
    if (id == null || !mounted) return;

    try {
      final user = await _apiService.getUser(id);
      if (!mounted) return;
      _showDetailDialog('Detail User #$id', _UserDetail(user: user));
    } catch (error) {
      if (mounted) _showMessage('Gagal mengambil User #$id: $error', isError: true);
    }
  }

  Future<void> _showAdminById() async {
    final id = await _askForId('Detail Admin', adminIdFromNim);
    if (id == null || !mounted) return;

    try {
      final admin = await _adminService.getAdmin(id);
      if (!mounted) return;
      _showDetailDialog('Detail Admin #$id', _AdminDetail(admin: admin));
    } catch (error) {
      if (mounted) _showMessage('Gagal mengambil Admin #$id: $error', isError: true);
    }
  }

  Future<void> _deleteAdminById() async {
    final id = await _askForId('Hapus Admin', adminIdFromNim);
    if (id == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penghapusan'),
        content: Text('Hapus Admin dengan ID $id?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _adminService.deleteAdmin(id);
      if (!mounted) return;
      _showMessage('Admin #$id berhasil dihapus', isError: false);
      _loadAdmins();
    } catch (error) {
      if (mounted) _showMessage('Gagal menghapus Admin: $error', isError: true);
    }
  }

  Future<int?> _askForId(String title, int initialValue) {
    return showDialog<int>(
      context: context,
      builder: (_) => _IdDialog(title: title, initialValue: initialValue),
    );
  }

  void _showDetailDialog(String title, Widget content) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _createUser() async {
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _UserFormDialog(title: 'Tambah User (POST)', submitLabel: 'POST'),
    );
    if (data == null || !mounted) return;
    try {
      await _apiService.createUser(User(
        id: userIdFromNim,
        name: data['name']!,
        email: data['email']!,
        city: '',
      ));
      if (!mounted) return;
      _showMessage('POST User #$userIdFromNim berhasil');
      _loadUsers();
    } catch (error) {
      if (mounted) _showMessage('Gagal POST User: $error', isError: true);
    }
  }

  Future<void> _updateUser() async {
    final id = await _askForId('PUT — Update User', userIdFromNim);
    if (id == null || !mounted) return;
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _UserFormDialog(title: 'Update User #$id (PUT)', submitLabel: 'PUT'),
    );
    if (data == null || !mounted) return;
    try {
      await _apiService.updateUser(id, name: data['name']!, email: data['email']!);
      if (!mounted) return;
      _showMessage('PUT User #$id berhasil (nama + email)');
      _loadUsers();
    } catch (error) {
      if (mounted) _showMessage('Gagal PUT User: $error', isError: true);
    }
  }

  Future<void> _patchUser() async {
    final id = await _askForId('PATCH — Tambah " - Flutter Developer"', userIdFromNim);
    if (id == null || !mounted) return;
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _UserFormDialog(
        title: 'Patch Nama User #$id',
        submitLabel: 'PATCH',
        includeEmail: false,
      ),
    );
    if (data == null || !mounted) return;
    try {
      await _apiService.patchUser(id, name: data['name']!);
      if (!mounted) return;
      _showMessage('PATCH User #$id berhasil (+ " - Flutter Developer")');
      _loadUsers();
    } catch (error) {
      if (mounted) _showMessage('Gagal PATCH User: $error', isError: true);
    }
  }

  Future<void> _deleteUser() async {
    final id = await _askForId('DELETE — Hapus User', userIdFromNim);
    if (id == null || !mounted) return;
    if (!await _confirm('Hapus User dengan ID $id?')) return;
    try {
      await _apiService.deleteUser(id);
      if (!mounted) return;
      _showMessage('DELETE User #$id berhasil');
      _loadUsers();
    } catch (error) {
      if (mounted) _showMessage('Gagal DELETE User: $error', isError: true);
    }
  }

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Ya')),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 8 — User & Admin'),
        actions: [
          IconButton(onPressed: _tabIndex == 0 ? _loadUsers : _loadAdmins, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _UserTab(
            future: _usersFuture,
            onDetail: _showUserById,
            onCreate: _createUser,
            onUpdate: _updateUser,
            onPatch: _patchUser,
            onDelete: _deleteUser,
          ),
          _AdminTab(future: _adminsFuture, onDetail: _showAdminById, onDelete: _deleteAdminById),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: 'User'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

class _UserTab extends StatelessWidget {
  final Future<List<User>>? future;
  final VoidCallback onDetail;
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onPatch;
  final VoidCallback onDelete;

  const _UserTab({
    required this.future,
    required this.onDetail,
    required this.onCreate,
    required this.onUpdate,
    required this.onPatch,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _DataList<User>(
      title: 'Daftar User',
      future: future,
      onDetail: onDetail,
      actions: [
        FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('POST User')),
        FilledButton.tonalIcon(onPressed: onUpdate, icon: const Icon(Icons.edit), label: const Text('PUT User')),
        FilledButton.tonalIcon(onPressed: onPatch, icon: const Icon(Icons.auto_fix_high), label: const Text('PATCH User')),
        OutlinedButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete), label: const Text('DELETE User')),
      ],
      itemBuilder: (user) => ListTile(
        leading: CircleAvatar(child: Text('${user.id}')),
        title: Text(user.name),
        subtitle: Text('${user.email}\nCity: ${user.city}'),
        isThreeLine: true,
      ),
    );
  }
}

class _AdminTab extends StatelessWidget {
  final Future<List<Admin>>? future;
  final VoidCallback onDetail;
  final VoidCallback onDelete;

  const _AdminTab({required this.future, required this.onDetail, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return _DataList<Admin>(
      title: 'Daftar Admin',
      future: future,
      onDetail: onDetail,
      actions: [
        FilledButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete), label: const Text('DELETE Admin')),
      ],
      itemBuilder: (admin) => ListTile(
        leading: CircleAvatar(child: Text('${admin.id}')),
        title: Text(admin.name),
        subtitle: Text('${admin.email}\nDepartment: ${admin.department}'),
        isThreeLine: true,
      ),
    );
  }
}

class _DataList<T> extends StatelessWidget {
  final String title;
  final Future<List<T>>? future;
  final Widget Function(T item) itemBuilder;
  final VoidCallback onDetail;
  final List<Widget> actions;

  const _DataList({required this.title, required this.future, required this.itemBuilder, required this.onDetail, required this.actions});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || future == null) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Gagal mengambil data:\n${snapshot.error}', textAlign: TextAlign.center));
        final items = snapshot.data ?? <T>[];
        return RefreshIndicator(
          onRefresh: () async => snapshot, // Tombol refresh AppBar melakukan request baru.
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: onDetail, icon: const Icon(Icons.search), label: const Text('Cari detail berdasarkan ID')),
              const SizedBox(height: 8),
              if (items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Data kosong'))),
              ...items.map((item) => Card(child: itemBuilder(item))),
            ],
          ),
        );
      },
    );
  }
}

class _UserDetail extends StatelessWidget {
  final User user;
  const _UserDetail({required this.user});

  @override
  Widget build(BuildContext context) => Text('ID: ${user.id}\nNama: ${user.name}\nEmail: ${user.email}\nKota: ${user.city}');
}

class _AdminDetail extends StatelessWidget {
  final Admin admin;
  const _AdminDetail({required this.admin});

  @override
  Widget build(BuildContext context) => Text('ID: ${admin.id}\nNama: ${admin.name}\nEmail: ${admin.email}\nDepartment: ${admin.department}');
}

class _IdDialog extends StatefulWidget {
  final String title;
  final int initialValue;

  const _IdDialog({required this.title, required this.initialValue});

  @override
  State<_IdDialog> createState() => _IdDialogState();
}

class _IdDialogState extends State<_IdDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(text: '${widget.initialValue}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'ID', border: OutlineInputBorder()),
          validator: (value) => int.tryParse(value ?? '') == null ? 'ID harus berupa angka' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        FilledButton(onPressed: _submit, child: const Text('Tampilkan')),
      ],
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final bool includeEmail;

  const _UserFormDialog({required this.title, required this.submitLabel, this.includeEmail = true});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(<String, String>{
      'name': _nameController.text.trim(),
      'email': widget.includeEmail ? _emailController.text.trim() : '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama'), validator: _required),
            if (widget.includeEmail)
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: _required),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
      ],
    );
  }
}
