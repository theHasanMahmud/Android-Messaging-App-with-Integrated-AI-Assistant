import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to manage chat preferences like pin, archive, hide, and block
class ChatPreferencesService {
  static final ChatPreferencesService _instance = ChatPreferencesService._();
  static ChatPreferencesService get instance => _instance;
  
  ChatPreferencesService._();
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Keys for storage
  static const String _pinnedChatsKey = 'pinned_chats';
  static const String _archivedChatsKey = 'archived_chats';
  static const String _hiddenChatsKey = 'hidden_chats';
  static const String _blockedUsersKey = 'blocked_users';
  static const String _hiddenChatPasswordKey = 'hidden_chat_password';
  static const String _hideOnlineStatusKey = 'hide_online_status';
  
  // Pin/Unpin Chat
  Future<void> togglePinChat(String channelId) async {
    final pinnedChats = await getPinnedChats();
    if (pinnedChats.contains(channelId)) {
      pinnedChats.remove(channelId);
    } else {
      pinnedChats.add(channelId);
    }
    await _storage.write(key: _pinnedChatsKey, value: pinnedChats.join(','));
  }
  
  Future<List<String>> getPinnedChats() async {
    final data = await _storage.read(key: _pinnedChatsKey);
    if (data == null || data.isEmpty) return [];
    return data.split(',');
  }
  
  Future<bool> isChatPinned(String channelId) async {
    final pinnedChats = await getPinnedChats();
    return pinnedChats.contains(channelId);
  }
  
  // Archive/Unarchive Chat
  Future<void> toggleArchiveChat(String channelId) async {
    final archivedChats = await getArchivedChats();
    if (archivedChats.contains(channelId)) {
      archivedChats.remove(channelId);
    } else {
      archivedChats.add(channelId);
    }
    await _storage.write(key: _archivedChatsKey, value: archivedChats.join(','));
  }
  
  Future<List<String>> getArchivedChats() async {
    final data = await _storage.read(key: _archivedChatsKey);
    if (data == null || data.isEmpty) return [];
    return data.split(',');
  }
  
  Future<bool> isChatArchived(String channelId) async {
    final archivedChats = await getArchivedChats();
    return archivedChats.contains(channelId);
  }
  
  // Hide/Unhide Chat
  Future<void> toggleHideChat(String channelId) async {
    final hiddenChats = await getHiddenChats();
    if (hiddenChats.contains(channelId)) {
      hiddenChats.remove(channelId);
    } else {
      hiddenChats.add(channelId);
    }
    await _storage.write(key: _hiddenChatsKey, value: hiddenChats.join(','));
  }
  
  Future<List<String>> getHiddenChats() async {
    final data = await _storage.read(key: _hiddenChatsKey);
    if (data == null || data.isEmpty) return [];
    return data.split(',');
  }
  
  Future<bool> isChatHidden(String channelId) async {
    final hiddenChats = await getHiddenChats();
    return hiddenChats.contains(channelId);
  }
  
  // Block/Unblock User
  Future<void> toggleBlockUser(String userId) async {
    final blockedUsers = await getBlockedUsers();
    if (blockedUsers.contains(userId)) {
      blockedUsers.remove(userId);
    } else {
      blockedUsers.add(userId);
    }
    await _storage.write(key: _blockedUsersKey, value: blockedUsers.join(','));
  }
  
  Future<List<String>> getBlockedUsers() async {
    final data = await _storage.read(key: _blockedUsersKey);
    if (data == null || data.isEmpty) return [];
    return data.split(',');
  }
  
  Future<bool> isUserBlocked(String userId) async {
    final blockedUsers = await getBlockedUsers();
    return blockedUsers.contains(userId);
  }
  
  // Hidden Chat Password
  Future<void> setHiddenChatPassword(String password) async {
    await _storage.write(key: _hiddenChatPasswordKey, value: password);
  }
  
  Future<String?> getHiddenChatPassword() async {
    return await _storage.read(key: _hiddenChatPasswordKey);
  }
  
  Future<bool> verifyHiddenChatPassword(String password) async {
    final storedPassword = await getHiddenChatPassword();
    return storedPassword == password;
  }
  
  Future<bool> hasHiddenChatPassword() async {
    final password = await getHiddenChatPassword();
    return password != null && password.isNotEmpty;
  }
  
  // Delete Chat (remove from local preferences)
  Future<void> deleteChat(String channelId) async {
    // Remove from all lists
    await _removeFromList(_pinnedChatsKey, channelId);
    await _removeFromList(_archivedChatsKey, channelId);
    await _removeFromList(_hiddenChatsKey, channelId);
  }
  
  Future<void> _removeFromList(String key, String value) async {
    final data = await _storage.read(key: key);
    if (data == null || data.isEmpty) return;
    
    final list = data.split(',');
    list.remove(value);
    await _storage.write(key: key, value: list.join(','));
  }
  
  // Online Status Visibility
  Future<void> setOnlineStatusVisibility(bool hideStatus) async {
    await _storage.write(key: _hideOnlineStatusKey, value: hideStatus.toString());
  }
  
  Future<bool> isOnlineStatusHidden() async {
    final value = await _storage.read(key: _hideOnlineStatusKey);
    return value == 'true';
  }
}
