# MiCel Demo

App de demostración **para clientes** **100% local** (SQLite). No necesita Laravel ni internet.

## Usuarios de prueba
| Usuario   | Clave | Notas        |
|-----------|-------|--------------|
| demo      | 1234  | Cliente normal |
| egor4206  | 1234  | VIP + órdenes |

## Cómo correr
```bash
cd micel_demo
flutter pub get
flutter run
# APK:
flutter build apk --release
```

## Funciones
- Login / logout
- Restablecer contraseña (usuario + teléfono)
- Cambiar contraseña (logueado)
- Editar perfil (nombre, teléfono)
- Vitrina de celulares predeterminados
- Órdenes de demo por usuario
- Coins y visitas en SQLite

Los datos se guardan en el celular: `micel_demo.db`.
