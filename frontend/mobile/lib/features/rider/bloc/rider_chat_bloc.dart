import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/models/rider_models.dart';
import '../data/repositories/rider_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────────

abstract class RiderChatEvent extends Equatable {
  const RiderChatEvent();
  @override
  List<Object?> get props => [];
}

class ConnectChat extends RiderChatEvent {
  final String deliveryId;
  final String wsUrl;
  final String userId;
  const ConnectChat({
    required this.deliveryId,
    required this.wsUrl,
    required this.userId,
  });
  @override
  List<Object?> get props => [deliveryId, wsUrl];
}

class SendChatMessage extends RiderChatEvent {
  final String body;
  const SendChatMessage(this.body);
  @override
  List<Object?> get props => [body];
}

class _MessageReceived extends RiderChatEvent {
  final ChatMessage message;
  const _MessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

class DisconnectChat extends RiderChatEvent {}

// ── States ───────────────────────────────────────────────────────────────────

abstract class RiderChatState extends Equatable {
  const RiderChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends RiderChatState {}

class ChatConnecting extends RiderChatState {}

class ChatConnected extends RiderChatState {
  final List<ChatMessage> messages;
  final String deliveryId;
  const ChatConnected({required this.messages, required this.deliveryId});
  @override
  List<Object?> get props => [messages, deliveryId];
}

class ChatError extends RiderChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class RiderChatBloc extends Bloc<RiderChatEvent, RiderChatState> {
  final RiderRepository _repository;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  String? _deliveryId;
  String? _userId;
  List<ChatMessage> _messages = [];

  RiderChatBloc(this._repository) : super(ChatInitial()) {
    on<ConnectChat>(_onConnect);
    on<SendChatMessage>(_onSend);
    on<_MessageReceived>(_onReceived);
    on<DisconnectChat>(_onDisconnect);
  }

  Future<void> _onConnect(
      ConnectChat event, Emitter<RiderChatState> emit) async {
    _deliveryId = event.deliveryId;
    _userId = event.userId;
    emit(ChatConnecting());
    try {
      _messages = await _repository.getChatHistory(event.deliveryId);
      _channel = WebSocketChannel.connect(Uri.parse(event.wsUrl));
      _wsSub = _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final msg = ChatMessage.fromJson(json);
            add(_MessageReceived(msg));
          } catch (_) {}
        },
        onError: (_) => add(DisconnectChat()),
        onDone: () => add(DisconnectChat()),
      );
      emit(ChatConnected(
          messages: List.from(_messages), deliveryId: event.deliveryId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSend(SendChatMessage event, Emitter<RiderChatState> emit) {
    if (_channel == null || _deliveryId == null || _userId == null) return;
    final payload = jsonEncode({
      'deliveryId': _deliveryId,
      'senderId': _userId,
      'senderRole': 'RIDER',
      'body': event.body,
    });
    _channel!.sink.add(payload);
  }

  void _onReceived(_MessageReceived event, Emitter<RiderChatState> emit) {
    _messages = [..._messages, event.message];
    if (_deliveryId != null) {
      emit(ChatConnected(
          messages: List.from(_messages), deliveryId: _deliveryId!));
    }
  }

  void _onDisconnect(DisconnectChat event, Emitter<RiderChatState> emit) {
    _wsSub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _wsSub = null;
    emit(ChatInitial());
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    _channel?.sink.close();
    return super.close();
  }
}
