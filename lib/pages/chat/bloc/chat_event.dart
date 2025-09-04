abstract class ChatEvent {}

class LoadAvailableUsers extends ChatEvent {}

class CreateChat extends ChatEvent {
  final int targetUserId;

  CreateChat({required this.targetUserId});
}

class LoadMyChats extends ChatEvent {}

class LoadChatMessages extends ChatEvent {
  final int chatId;

  LoadChatMessages({required this.chatId});
}

class SendMessage extends ChatEvent {
  final int chatId;
  final String content;

  SendMessage({
    required this.chatId,
    required this.content,
  });
}

class MarkChatAsRead extends ChatEvent {
  final int chatId;

  MarkChatAsRead({required this.chatId});
}

class SelectChat extends ChatEvent {
  final Map<String, dynamic> chat;

  SelectChat({required this.chat});
}

class CloseChatPopup extends ChatEvent {}

class RefreshChats extends ChatEvent {}
