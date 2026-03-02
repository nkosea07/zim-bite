import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/rider_chat_bloc.dart';
import '../../bloc/rider_dashboard_bloc.dart';
import '../../data/models/rider_models.dart';
import '../../data/repositories/rider_repository.dart';

class RiderChatScreen extends StatefulWidget {
  final String deliveryId;

  const RiderChatScreen({super.key, required this.deliveryId});

  @override
  State<RiderChatScreen> createState() => _RiderChatScreenState();
}

class _RiderChatScreenState extends State<RiderChatScreen> {
  late final RiderChatBloc _chatBloc;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _customerPhone;

  @override
  void initState() {
    super.initState();
    _chatBloc = RiderChatBloc(context.read<RiderRepository>());
    _connectChat();
    _resolveCustomerPhone();
  }

  Future<void> _connectChat() async {
    final tokenStorage = context.read<TokenStorage>();
    final userId = await tokenStorage.accessToken ?? 'rider';
    final wsUrl =
        '${EnvConfig.wsBaseUrl}/chat/${widget.deliveryId}';
    if (mounted) {
      _chatBloc.add(ConnectChat(
        deliveryId: widget.deliveryId,
        wsUrl: wsUrl,
        userId: userId,
      ));
    }
  }

  void _resolveCustomerPhone() {
    final dashState = context.read<RiderDashboardBloc>().state;
    if (dashState is RiderDashboardLoaded) {
      final all = [...dashState.active, ...dashState.available];
      try {
        final delivery =
            all.firstWhere((d) => d.id == widget.deliveryId);
        setState(() => _customerPhone = delivery.customerPhone);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _chatBloc.add(DisconnectChat());
    _chatBloc.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _chatBloc.add(SendChatMessage(text));
    _textController.clear();
  }

  Future<void> _callCustomer() async {
    if (_customerPhone == null) return;
    final uri = Uri.parse('tel:$_customerPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Chat',
                style: TextStyle(
                  color: AppColors.warmGrey900,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                'Delivery chat',
                style: TextStyle(
                  color: AppColors.warmGrey500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            if (_customerPhone != null)
              IconButton(
                icon: const Icon(Icons.phone_outlined,
                    color: AppColors.success),
                onPressed: _callCustomer,
                tooltip: 'Call customer',
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<RiderChatBloc, RiderChatState>(
                listener: (context, state) {
                  if (state is ChatConnected) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state is ChatConnecting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.brandOrange),
                    );
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 40),
                          const SizedBox(height: 12),
                          Text(state.message,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _connectChat,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ChatInitial) {
                    return const Center(
                      child: Text(
                        'Connecting...',
                        style: TextStyle(color: AppColors.warmGrey500),
                      ),
                    );
                  }

                  final messages =
                      state is ChatConnected ? state.messages : <ChatMessage>[];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet.\nSend the first message!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.warmGrey500),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _ChatBubble(message: msg);
                    },
                  );
                },
              ),
            ),
            _InputBar(
              controller: _textController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isRider = message.senderRole.toUpperCase() == 'RIDER';
    final timeStr = DateFormat('HH:mm').format(message.sentAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isRider ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isRider) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.warmGrey100,
              child: const Icon(Icons.person,
                  size: 16, color: AppColors.warmGrey500),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isRider
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isRider ? AppColors.brandOrange : AppColors.warmGrey100,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isRider ? 16 : 4),
                    bottomRight: Radius.circular(isRider ? 4 : 16),
                  ),
                ),
                child: Text(
                  message.body,
                  style: TextStyle(
                    color: isRider ? Colors.white : AppColors.warmGrey900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.warmGrey500,
                ),
              ),
            ],
          ),
          if (isRider) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.brandOrange.withValues(alpha: 0.15),
              child: const Icon(Icons.delivery_dining,
                  size: 16, color: AppColors.brandOrange),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle:
                    const TextStyle(color: AppColors.warmGrey300),
                filled: true,
                fillColor: AppColors.warmGrey50,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.brandOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
