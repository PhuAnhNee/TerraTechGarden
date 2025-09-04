import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../api/terra_api.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final String? _storedToken;
  Map<String, dynamic>? _selectedChat;
  List<Map<String, dynamic>> _currentMessages = [];
  List<Map<String, dynamic>> _availableUsers = [];
  List<Map<String, dynamic>> _myChats = [];

  ChatBloc({String? storedToken})
      : _storedToken = storedToken,
        super(ChatInitial()) {
    on<LoadAvailableUsers>(_onLoadAvailableUsers);
    on<CreateChat>(_onCreateChat);
    on<LoadMyChats>(_onLoadMyChats);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkChatAsRead>(_onMarkChatAsRead);
    on<SelectChat>(_onSelectChat);
    on<CloseChatPopup>(_onCloseChatPopup);
    on<RefreshChats>(_onRefreshChats);

    _debugToken();
  }

  void _debugToken() {
    if (_storedToken != null && _storedToken!.isNotEmpty) {
      developer.log(
          'ChatBloc initialized with token: ${_storedToken!.substring(0, 20)}...',
          name: 'ChatBloc');
    } else {
      developer.log('ChatBloc initialized WITHOUT token!', name: 'ChatBloc');
    }
  }

  Dio _getDio() {
    final dio = Dio();

    if (_storedToken != null && _storedToken!.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $_storedToken';
      developer.log(
          '✅ Authorization header set: Bearer ${_storedToken!.substring(0, 20)}...',
          name: 'ChatBloc');
    } else {
      developer.log('❌ NO TOKEN PROVIDED - This will cause 401/500 errors!',
          name: 'ChatBloc');
    }

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('🚀 REQUEST: ${options.method} ${options.path}',
            name: 'ChatBloc');
        developer.log('📋 Headers: ${options.headers}', name: 'ChatBloc');
        if (options.data != null) {
          developer.log('📤 Data: ${options.data}', name: 'ChatBloc');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            '✅ RESPONSE: ${response.statusCode} ${response.statusMessage}',
            name: 'ChatBloc');
        developer.log('📥 Response data: ${response.data}', name: 'ChatBloc');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log('❌ ERROR: ${error.response?.statusCode} ${error.message}',
            name: 'ChatBloc');
        developer.log('📥 Error response: ${error.response?.data}',
            name: 'ChatBloc');
        handler.next(error);
      },
    ));

    return dio;
  }

  Future<void> _onLoadAvailableUsers(
      LoadAvailableUsers event, Emitter<ChatState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(ChatError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('👥 Loading available users...', name: 'ChatBloc');

    // Only emit loading if we don't have cached data
    if (_availableUsers.isEmpty) {
      emit(ChatLoading());
    }

    try {
      final response = await _getDio().get(TerraApi.getAvailableUsers());

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData.containsKey('data')) {
          _availableUsers =
              List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else {
          // Handle direct array response
          _availableUsers = List<Map<String, dynamic>>.from(responseData ?? []);
        }

        developer.log('✅ Loaded ${_availableUsers.length} available users',
            name: 'ChatBloc');
        emit(AvailableUsersLoaded(_availableUsers));
      } else {
        emit(ChatError('Failed to load available users'));
      }
    } catch (e) {
      developer.log('💥 Error loading available users: $e', name: 'ChatBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ChatError('Authentication failed. Please log in again.'));
        } else {
          String errorMessage = 'Network error';
          if (e.response?.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ?? e.message ?? errorMessage;
          }
          emit(ChatError(errorMessage));
        }
      } else {
        emit(ChatError('Failed to load available users: $e'));
      }
    }
  }

  Future<void> _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(ChatError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('💬 Creating chat with user ${event.targetUserId}...',
        name: 'ChatBloc');
    emit(ChatLoading());

    try {
      final response = await _getDio().post(
        TerraApi.createChat(),
        data: {
          'targetUserId': event.targetUserId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 201 &&
            responseData.containsKey('data')) {
          final chat = responseData['data'] as Map<String, dynamic>;
          developer.log('✅ Chat created with ID: ${chat['chatId']}',
              name: 'ChatBloc');
          emit(ChatCreated(chat));

          // Refresh chats list after creating new chat
          add(LoadMyChats());
        } else {
          emit(ChatError('Invalid response format when creating chat'));
        }
      } else {
        emit(ChatError('Failed to create chat'));
      }
    } catch (e) {
      developer.log('💥 Error creating chat: $e', name: 'ChatBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ChatError('Authentication failed. Please log in again.'));
        } else {
          String errorMessage = 'Network error';
          if (e.response?.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ?? e.message ?? errorMessage;
          }
          emit(ChatError(errorMessage));
        }
      } else {
        emit(ChatError('Failed to create chat: $e'));
      }
    }
  }

  Future<void> _onLoadMyChats(
      LoadMyChats event, Emitter<ChatState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(ChatError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('📱 Loading my chats...', name: 'ChatBloc');

    // Only emit loading if we don't have cached data
    if (_myChats.isEmpty) {
      emit(ChatLoading());
    }

    try {
      final response = await _getDio().get(TerraApi.getMyChats());

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData.containsKey('data')) {
          _myChats =
              List<Map<String, dynamic>>.from(responseData['data'] ?? []);
          developer.log('✅ Loaded ${_myChats.length} chats', name: 'ChatBloc');
          emit(MyChatsLoaded(_myChats));
        } else {
          emit(ChatError('Invalid response format when loading chats'));
        }
      } else {
        emit(ChatError('Failed to load chats'));
      }
    } catch (e) {
      developer.log('💥 Error loading chats: $e', name: 'ChatBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ChatError('Authentication failed. Please log in again.'));
        } else {
          String errorMessage = 'Network error';
          if (e.response?.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ?? e.message ?? errorMessage;
          }
          emit(ChatError(errorMessage));
        }
      } else {
        emit(ChatError('Failed to load chats: $e'));
      }
    }
  }

  Future<void> _onLoadChatMessages(
      LoadChatMessages event, Emitter<ChatState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(ChatError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('💬 Loading messages for chat ${event.chatId}...',
        name: 'ChatBloc');
    emit(ChatLoading());

    try {
      final response = await _getDio()
          .get(TerraApi.getChatMessages(event.chatId.toString()));

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData.containsKey('data')) {
          _currentMessages =
              List<Map<String, dynamic>>.from(responseData['data'] ?? []);
          developer.log('✅ Loaded ${_currentMessages.length} messages',
              name: 'ChatBloc');

          // Emit with chat info
          final chatInfo = _selectedChat ?? {};
          emit(ChatMessagesLoaded(_currentMessages, chatInfo));
        } else {
          emit(ChatError('Invalid response format when loading messages'));
        }
      } else {
        emit(ChatError('Failed to load messages'));
      }
    } catch (e) {
      developer.log('💥 Error loading messages: $e', name: 'ChatBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ChatError('Authentication failed. Please log in again.'));
        } else {
          String errorMessage = 'Network error';
          if (e.response?.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ?? e.message ?? errorMessage;
          }
          emit(ChatError(errorMessage));
        }
      } else {
        emit(ChatError('Failed to load messages: $e'));
      }
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(ChatError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('📤 Sending message to chat ${event.chatId}...',
        name: 'ChatBloc');

    try {
      final response = await _getDio().post(
        TerraApi.sendMessage(),
        data: {
          'chatId': event.chatId,
          'content': event.content,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 201 &&
            responseData.containsKey('data')) {
          final message = responseData['data'] as Map<String, dynamic>;
          developer.log('✅ Message sent with ID: ${message['messageId']}',
              name: 'ChatBloc');

          // Add message to current messages and emit updated state
          _currentMessages.add(message);
          final chatInfo = _selectedChat ?? {};
          emit(ChatMessagesLoaded(List.from(_currentMessages), chatInfo));
        } else {
          emit(ChatError('Invalid response format when sending message'));
        }
      } else {
        emit(ChatError('Failed to send message'));
      }
    } catch (e) {
      developer.log('💥 Error sending message: $e', name: 'ChatBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ChatError('Authentication failed. Please log in again.'));
        } else {
          String errorMessage = 'Network error';
          if (e.response?.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ?? e.message ?? errorMessage;
          }
          emit(ChatError(errorMessage));
        }
      } else {
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  Future<void> _onMarkChatAsRead(
      MarkChatAsRead event, Emitter<ChatState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      return; // Silent fail for read status
    }

    developer.log('👁️ Marking chat ${event.chatId} as read...',
        name: 'ChatBloc');

    try {
      final response = await _getDio().put(
        TerraApi.markChatAsRead(event.chatId.toString()),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200) {
          developer.log('✅ Chat marked as read', name: 'ChatBloc');
          // Don't emit a separate state, just log success
        }
      }
    } catch (e) {
      developer.log('💥 Error marking chat as read: $e', name: 'ChatBloc');
      // Don't emit error for read status - it's not critical
    }
  }

  void _onSelectChat(SelectChat event, Emitter<ChatState> emit) {
    developer.log('🎯 Selecting chat: ${event.chat['chatId']}',
        name: 'ChatBloc');
    _selectedChat = event.chat;
    // Don't emit a state here, let LoadChatMessages handle the UI update
  }

  void _onCloseChatPopup(CloseChatPopup event, Emitter<ChatState> emit) {
    developer.log('❌ Closing chat popup', name: 'ChatBloc');
    _selectedChat = null;
    _currentMessages.clear();

    // Return to the appropriate list view based on cached data
    if (_availableUsers.isNotEmpty) {
      emit(AvailableUsersLoaded(_availableUsers));
    } else if (_myChats.isNotEmpty) {
      emit(MyChatsLoaded(_myChats));
    } else {
      emit(ChatInitial());
    }
  }

  void _onRefreshChats(RefreshChats event, Emitter<ChatState> emit) {
    developer.log('🔄 Refreshing chats', name: 'ChatBloc');
    // Clear cache and reload
    _myChats.clear();
    add(LoadMyChats());
  }
}
