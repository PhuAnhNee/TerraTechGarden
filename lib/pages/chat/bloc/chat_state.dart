abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}

class AvailableUsersLoaded extends ChatState {
  final List<Map<String, dynamic>> availableUsers;

  AvailableUsersLoaded(this.availableUsers);
}

class ChatCreated extends ChatState {
  final Map<String, dynamic> chat;

  ChatCreated(this.chat);
}

class MyChatsLoaded extends ChatState {
  final List<Map<String, dynamic>> chats;

  MyChatsLoaded(this.chats);
}

class ChatMessagesLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;
  final Map<String, dynamic> chatInfo;

  ChatMessagesLoaded(this.messages, this.chatInfo);
}

class MessageSent extends ChatState {
  final Map<String, dynamic> message;

  MessageSent(this.message);
}

class ChatMarkedAsRead extends ChatState {}

class ChatSelected extends ChatState {
  final Map<String, dynamic> selectedChat;

  ChatSelected(this.selectedChat);
}

class ChatPopupClosed extends ChatState {}

class ChatOperationSuccess extends ChatState {
  final String message;

  ChatOperationSuccess(this.message);
}
