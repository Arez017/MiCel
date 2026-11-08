import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Cambia según dónde corras la app:
/// - Emulador Android: 10.0.2.2
/// - Celular físico (misma WiFi): IP de tu PC, ej. 192.168.1.10
/// - Windows / Chrome: 127.0.0.1
const String kChatBaseUrl = 'http://10.0.2.2:8001';

void main() => runApp(const MicelChatApp());

class MicelChatApp extends StatelessWidget {
  const MicelChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiCEL Chatbot IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFFF1440),
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      ),
      home: const ChatPage(),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  final String? tag;
  final double? confidence;
  _Msg(this.text, {required this.isUser, this.tag, this.confidence});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _sending = false;

  List<String> _suggestions = const [
    'Hola',
    '¿Dónde está mi orden?',
    '¿Qué son los coins?',
    'Garantía',
    '¿Qué llevo al taller?',
  ];

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(
      '¡Hola! Soy el asistente MiCEL.\n'
      'Red neuronal MLP propia (NumPy + backpropagation).\n'
      'Pregúntame por órdenes, coins, garantía o el taller.',
      isUser: false,
      tag: 'sistema',
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _msgs.add(_Msg(text, isUser: true));
      _sending = true;
      if (preset == null) _ctrl.clear();
    });
    _jumpEnd();

    try {
      final res = await http
          .post(
            Uri.parse('$kChatBaseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'message': text}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final reply = (data['reply'] ?? 'Sin respuesta').toString();
      final tag = data['tag']?.toString();
      final conf = (data['confidence'] is num)
          ? (data['confidence'] as num).toDouble()
          : null;
      final sugg = data['suggestions'];
      final nextChips = <String>[];
      if (sugg is List) {
        for (final s in sugg) {
          final x = s.toString().trim();
          if (x.isNotEmpty) nextChips.add(x);
        }
      }

      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(reply, isUser: false, tag: tag, confidence: conf));
        if (nextChips.isNotEmpty) _suggestions = nextChips;
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(
          'No pude conectar con la IA.\n'
          '1) ¿Está corriendo uvicorn en el puerto 8001?\n'
          '2) Revisa kChatBaseUrl en main.dart\n'
          'Error: $e',
          isUser: false,
        ));
        _sending = false;
      });
    }
    _jumpEnd();
  }

  void _jumpEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asistente MiCEL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            Text('Red neuronal propia · MLP', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF141416),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(14),
              itemCount: _msgs.length + (_sending ? 1 : 0),
              itemBuilder: (_, i) {
                if (_sending && i == _msgs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('Pensando…', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  );
                }
                return _Bubble(msg: _msgs[i]);
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = _suggestions[i];
                return ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: _sending ? null : () => _send(s),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta…',
                        filled: true,
                        fillColor: const Color(0xFF1C1C1F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : () => _send(),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFFF1440)),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFF1440) : const Color(0xFF1C1C1F),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFF2A2A2E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.text, style: const TextStyle(height: 1.35, fontSize: 14)),
            if (!isUser && msg.tag != null && msg.tag != 'sistema') ...[
              const SizedBox(height: 6),
              Text(
                'tag: ${msg.tag}'
                '${msg.confidence != null ? ' · conf: ${(msg.confidence! * 100).toStringAsFixed(1)}%' : ''}',
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
