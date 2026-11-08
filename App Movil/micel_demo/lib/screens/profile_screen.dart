import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../services/session.dart';
import '../theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _u;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final u = await DatabaseHelper.instance.getUser(Session.username);
    setState(() => _u = u);
    if (u != null) await Session.save(u);
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _u?['name']?.toString() ?? '');
    final phone = TextEditingController(text: _u?['phone']?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 10),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.updateProfile(Session.username, name: name.text.trim(), phone: phone.text.trim());
      await _reload();
    }
  }

  Future<void> _changePass() async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final nueva2 = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: actual, obscureText: true, decoration: const InputDecoration(labelText: 'Actual')),
            const SizedBox(height: 10),
            TextField(controller: nueva, obscureText: true, decoration: const InputDecoration(labelText: 'Nueva')),
            const SizedBox(height: 10),
            TextField(controller: nueva2, obscureText: true, decoration: const InputDecoration(labelText: 'Repetir nueva')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok != true) return;
    if (nueva.text != nueva2.text) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No coinciden')));
      return;
    }
    final err = await DatabaseHelper.instance.changePassword(
      username: Session.username,
      actual: actual.text,
      nueva: nueva.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Contraseña actualizada')));
  }

  Future<void> _logout() async {
    await Session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = _u;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: u == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (u['name']?.toString().isNotEmpty == true)
                          ? u['name'].toString().substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(u['name']?.toString() ?? '', textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                Text('@${u['username']}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
                if ((u['es_vip'] as int? ?? 0) == 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('★ Cliente VIP', textAlign: TextAlign.center, style: TextStyle(color: AppColors.warn, fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(height: 18),
                _tile(Icons.phone, 'Teléfono', u['phone']?.toString() ?? '—'),
                _tile(Icons.monetization_on, 'Coins', '${u['coins']}'),
                _tile(Icons.storefront, 'Visitas', '${u['visits']}'),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Editar datos'),
                  onTap: _editProfile,
                ),
                const SizedBox(height: 8),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.lock, color: AppColors.primary),
                  title: const Text('Cambiar contraseña'),
                  onTap: _changePass,
                ),
                const SizedBox(height: 8),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.logout, color: Color(0xFFFF8A8A)),
                  title: const Text('Cerrar sesión', style: TextStyle(color: Color(0xFFFF8A8A))),
                  onTap: _logout,
                ),
              ],
            ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
        ],
      ),
    );
  }
}
