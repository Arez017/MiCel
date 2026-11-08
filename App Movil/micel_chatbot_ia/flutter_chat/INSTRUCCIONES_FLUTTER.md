# Interfaz Flutter del chatbot (red neuronal propia)

## Si YA tienes proyecto Flutter (micel)

1. Copia `lib/main.dart` de esta carpeta **o** integra la pantalla `ChatPage` en tu app.
2. En `pubspec.yaml` asegúrate de tener:
```yaml
dependencies:
  http: ^1.2.0
```
3. Edita la URL al inicio de `main.dart`:
```dart
const String kChatBaseUrl = 'http://10.0.2.2:8001'; // emulador
// const String kChatBaseUrl = 'http://192.168.x.x:8001'; // celular real
// const String kChatBaseUrl = 'http://127.0.0.1:8001'; // Windows desktop / chrome
```
4. Terminal 1 (API):
```powershell
python -m uvicorn api.server:app --host 0.0.0.0 --port 8001
```
5. Terminal 2:
```powershell
flutter pub get
flutter run
```

## Proyecto nuevo solo para el examen
```powershell
flutter create micel_chat_app
cd micel_chat_app
```
Copia este `main.dart` sobre `lib/main.dart`, agrega `http` al pubspec, y corre.

## Android cleartext (HTTP)
En `android/app/src/main/AndroidManifest.xml` dentro de `<application>`:
```xml
android:usesCleartextTraffic="true"
```
