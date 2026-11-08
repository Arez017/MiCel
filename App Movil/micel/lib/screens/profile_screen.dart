import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      await ApiService.me();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditPerfil() async {
    final nameCtrl = TextEditingController(text: ClientSession.nombre);
    final userCtrl = TextEditingController(text: ClientSession.username);
    final phoneCtrl = TextEditingController(text: ClientSession.phone);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Editar perfil',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: userCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Usuario (login)',
                        border: OutlineInputBorder(),
                        helperText: 'Letras, números, _ o -',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length < 3) {
                          return 'Mínimo 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModal(() => saving = true);
                                try {
                                  await ApiService.updatePerfil(
                                    name: nameCtrl.text.trim(),
                                    username: userCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✓ Perfil actualizado'),
                                        backgroundColor: Color(0xFF16A34A),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModal(() => saving = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text('$e'),
                                        backgroundColor: AppColors.danger,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(saving ? 'Guardando…' : 'Guardar cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openChangePassword() async {
    final actualCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    bool show = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Cambiar contraseña',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: actualCtrl,
                      obscureText: !show,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña actual',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Obligatoria' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nuevaCtrl,
                      obscureText: !show,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contraseña',
                        border: OutlineInputBorder(),
                        helperText: 'Mínimo 4 caracteres',
                      ),
                      validator: (v) {
                        if (v == null || v.length < 4) return 'Mínimo 4 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confCtrl,
                      obscureText: !show,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nueva',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(show ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setModal(() => show = !show),
                        ),
                      ),
                      validator: (v) {
                        if (v != nuevaCtrl.text) return 'No coincide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModal(() => saving = true);
                                try {
                                  await ApiService.changePassword(
                                    passwordActual: actualCtrl.text,
                                    password: nuevaCtrl.text,
                                    passwordConfirmation: confCtrl.text,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✓ Contraseña actualizada'),
                                        backgroundColor: Color(0xFF16A34A),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModal(() => saving = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text('$e'),
                                        backgroundColor: AppColors.danger,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(saving ? 'Guardando…' : 'Cambiar contraseña'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = ClientSession.nombre.isNotEmpty
        ? ClientSession.nombre
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : 'C';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Mi perfil',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900)),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.5),
                        gradient: const LinearGradient(
                          colors: [Color(0x33FF1440), Color(0x15FF1440)],
                        ),
                      ),
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(height: 14),
                    Text(ClientSession.nombre,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900)),
                    if (ClientSession.username.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('@${ClientSession.username}',
                          style: const TextStyle(color: AppColors.gray400, fontSize: 13)),
                    ],
                    if (ClientSession.esVip) ...[
                      const SizedBox(height: 6),
                      const Text('⭐ Cliente VIP',
                          style: TextStyle(
                              color: AppColors.warning, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 16),
                    _infoRow(Icons.qr_code_rounded, 'Código', ClientSession.code),
                    _infoRow(Icons.person_outline, 'Usuario', ClientSession.username),
                    _infoRow(Icons.phone_rounded, 'Teléfono', ClientSession.phone),
                    _infoRow(Icons.monetization_on_rounded, 'Coins',
                        '${ClientSession.coins} (≈ Bs ${ClientSession.coinsValorBs.toStringAsFixed(0)})'),
                    _infoRow(Icons.confirmation_number_outlined, 'Visitas',
                        '${ClientSession.visits}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _actionTile(
                icon: Icons.edit_outlined,
                title: 'Editar datos',
                subtitle: 'Nombre, usuario y teléfono',
                onTap: _openEditPerfil,
              ),
              _actionTile(
                icon: Icons.lock_outline_rounded,
                title: 'Cambiar contraseña',
                subtitle: 'Actualiza tu clave de acceso',
                onTap: _openChangePassword,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  label: const Text('Cerrar sesión',
                      style: TextStyle(
                          color: AppColors.danger, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.gray900)),
                      Text(subtitle,
                          style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gray400),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(k, style: const TextStyle(color: AppColors.gray400, fontSize: 13)),
          ),
          Expanded(
            child: Text(v.isEmpty ? '—' : v,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900)),
          ),
        ],
      ),
    );
  }
}
