import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../navigation/routes.dart';

class ChatScreen extends StatefulWidget {
  final String? authToken;

  const ChatScreen({super.key, this.authToken});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, dynamic>? selectedChat;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.authToken != null &&
        widget.authToken!.isNotEmpty &&
        !_isInitialized) {
      _isInitialized = true;
      // Load both available users and existing chats
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatBloc>().add(LoadAvailableUsers());
        context.read<ChatBloc>().add(LoadMyChats());
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        // Handle state changes that need navigation or UI updates
        if (state is ChatCreated) {
          // When a new chat is created, open it immediately
          _openChat(state.chat);
        } else if (state is ChatError &&
            state.message.contains('Authentication')) {
          // Handle authentication errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D7020),
          title: Text(
            selectedChat != null
                ? 'Chat với ${_getOtherUserName(selectedChat!)}'
                : 'Chat',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (selectedChat != null) {
                setState(() {
                  selectedChat = null;
                });
                // Reset to list view - reload data
                context.read<ChatBloc>().add(LoadAvailableUsers());
                context.read<ChatBloc>().add(LoadMyChats());
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: widget.authToken == null || widget.authToken!.isEmpty
              ? _buildLoginPrompt()
              : selectedChat == null
                  ? _buildChatListView()
                  : _buildChatMessagesView(),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Color(0xFF1D7020),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng nhập để trò chuyện đầy đủ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn cần đăng nhập để có thể chat với quản lý và nhận hỗ trợ',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7020),
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatListView() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        // Show loading only for the first load
        if (state is ChatLoading && !_hasAnyData(context)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatBloc>().add(LoadAvailableUsers());
                    context.read<ChatBloc>().add(LoadMyChats());
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: const Color(0xFF1D7020),
                child: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Quản lý', icon: Icon(Icons.support_agent)),
                    Tab(text: 'Cuộc trò chuyện', icon: Icon(Icons.chat)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAvailableUsersTab(state),
                    _buildMyChatsTab(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to check if we have any cached data
  bool _hasAnyData(BuildContext context) {
    final currentState = context.read<ChatBloc>().state;
    return currentState is AvailableUsersLoaded ||
        currentState is MyChatsLoaded;
  }

  Widget _buildAvailableUsersTab(ChatState state) {
    if (state is AvailableUsersLoaded) {
      final managers = state.availableUsers
          .where((user) => user['roleName'] == 'Manager')
          .toList();

      if (managers.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Không có quản lý nào có sẵn',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<ChatBloc>().add(LoadAvailableUsers());
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: managers.length,
          itemBuilder: (context, index) {
            final manager = managers[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1D7020),
                  child: Text(
                    manager['fullName']?[0]?.toUpperCase() ?? 'M',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  manager['fullName'] ?? 'Manager',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manager['email'] ?? ''),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: manager['status'] == 'Active'
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        manager['status'] ?? 'Unknown',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                trailing: manager['hasExistingChat'] == true
                    ? const Icon(Icons.chat, color: Color(0xFF1D7020))
                    : const Icon(Icons.add_comment, color: Colors.grey),
                onTap: () => _handleManagerTap(manager),
              ),
            );
          },
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Kéo xuống để tải danh sách quản lý',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatBloc>().add(LoadAvailableUsers());
            },
            child: const Text('Tải danh sách'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyChatsTab(ChatState state) {
    if (state is MyChatsLoaded) {
      if (state.chats.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Chưa có cuộc trò chuyện nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Hãy bắt đầu chat với quản lý từ tab bên trái',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<ChatBloc>().add(LoadMyChats());
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.chats.length,
          itemBuilder: (context, index) {
            final chat = state.chats[index];
            final otherUserName = _getOtherUserName(chat);
            final lastMessage = chat['lastMessage'];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1D7020),
                  child: Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: lastMessage != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lastMessage['senderName'] ?? 'Unknown'}: ${lastMessage['content'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMessageTime(lastMessage['sentAt']),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    : const Text('Chưa có tin nhắn'),
                trailing: lastMessage != null && lastMessage['isRead'] == false
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D7020),
                          shape: BoxShape.circle,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openChat(chat),
              ),
            );
          },
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Kéo xuống để tải cuộc trò chuyện',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatBloc>().add(LoadMyChats());
            },
            child: const Text('Tải cuộc trò chuyện'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessagesView() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatMessagesLoaded) {
          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có tin nhắn nào\nHãy bắt đầu cuộc trò chuyện!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              state.messages[state.messages.length - 1 - index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),
              _buildMessageInput(),
            ],
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (selectedChat != null) {
                      context.read<ChatBloc>().add(
                            LoadChatMessages(chatId: selectedChat!['chatId']),
                          );
                    }
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMyMessage = _isMyMessage(message);

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMyMessage ? const Color(0xFF1D7020) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
            bottomRight: Radius.circular(isMyMessage ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMyMessage)
              Text(
                message['senderName'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message['content'] ?? '',
              style: TextStyle(
                color: isMyMessage ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message['sentAt']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMyMessage ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (isMyMessage) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message['isRead'] == true ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message['isRead'] == true
                        ? Colors.blue
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF1D7020)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _handleManagerTap(Map<String, dynamic> manager) {
    // Prevent multiple taps
    if (selectedChat != null) return;

    if (manager['hasExistingChat'] == true &&
        manager['existingChatId'] != null) {
      // Open existing chat
      final chatData = {
        'chatId': manager['existingChatId'],
        'user1Name': manager['fullName'],
        'user2Name': manager['fullName'],
        'user1Role': 'User',
        'user2Role': 'Manager',
      };
      _openChat(chatData);
    } else {
      // Create new chat
      context.read<ChatBloc>().add(CreateChat(targetUserId: manager['userId']));
    }
  }

  void _openChat(Map<String, dynamic> chat) {
    if (selectedChat != null) return; // Prevent multiple opens

    setState(() {
      selectedChat = chat;
    });

    context.read<ChatBloc>().add(LoadChatMessages(chatId: chat['chatId']));
    context.read<ChatBloc>().add(MarkChatAsRead(chatId: chat['chatId']));
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || selectedChat == null) return;

    context.read<ChatBloc>().add(SendMessage(
          chatId: selectedChat!['chatId'],
          content: _messageController.text.trim(),
        ));

    _messageController.clear();
  }

  String _getOtherUserName(Map<String, dynamic> chat) {
    // You'll need to implement logic to determine which user is "the other user"
    // This depends on how you store the current user info
    return chat['user2Name'] ?? chat['user1Name'] ?? 'Unknown User';
  }

  bool _isMyMessage(Map<String, dynamic> message) {
    // You'll need to implement logic to check if this message was sent by the current user
    // This depends on how you store the current user info
    return message['senderRole'] ==
        'User'; // Assuming current user is always 'User'
  }

  String _formatMessageTime(String? sentAtString) {
    if (sentAtString == null) return '';

    try {
      // Parse the UTC time
      final sentAt = DateTime.parse(sentAtString).toUtc();
      // Convert to local time (Vietnam timezone is UTC+7)
      final localTime = sentAt.add(const Duration(hours: 7));
      final now = DateTime.now();

      final difference = now.difference(localTime);

      if (difference.inMinutes < 1) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        // Format as date
        return '${localTime.day}/${localTime.month}/${localTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
