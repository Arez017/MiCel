import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';

class _Msg {
  final String text;
  final bool isUser;
  final String? source;
  _Msg(this.text, {required this.isUser, this.source});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(
      '¡Hola! Soy el asistente MiCEL 🔧\nPregúntame por tu orden, coins, garantía o el taller.',
      isUser: false,
      source: 'micel',
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
    _scrollToEnd();

    try {
      final history = _msgs
          .where((m) => m.text.isNotEmpty)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();
      // no incluir el mensaje actual dos veces: API recibe message aparte
      if (history.isNotEmpty && history.last['content'] == text) {
        history.removeLast();
      }

      final res = await ApiService.chat(text, history: history);
      final reply = (res['reply'] ?? 'Sin respuesta').toString();
      final source = res['source']?.toString();
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(reply, isUser: false, source: source));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(
          'No pude conectar con el asistente.\n$e',
          isUser: false,
        ));
        _sending = false;
      });
    }
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '¿Dónde está mi orden?',
      '¿Qué son los coins?',
      'Garantía',
      '¿Qué llevo al taller?',
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asistente MiCEL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text('Demo IA · taller',
                style: TextStyle(fontSize: 11, color: AppColors.gray400)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemCount: _msgs.length + (_sending ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_sending && i == _msgs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Escribiendo…',
                            style: TextStyle(color: AppColors.gray400, fontSize: 13)),
                      ],
                    ),
                  );
                }
                final m = _msgs[i];
                return _Bubble(msg: m);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: suggestions
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          onPressed: _sending ? null : () => _send(s),
                          backgroundColor: AppColors.surface2,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
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
                      fillColor: AppColors.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : () => _send(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
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
    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = msg.isUser ? AppColors.primary : AppColors.surface2;
    final fg = msg.isUser ? Colors.white : AppColors.gray900;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: msg.isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(msg.text, style: TextStyle(color: fg, height: 1.35, fontSize: 14)),
      ),
    );
  }
}
