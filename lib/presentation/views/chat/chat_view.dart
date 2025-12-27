import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adda_time/presentation/l10n/app_localizations.dart';
import 'package:adda_time/core/constants/enums/router_enum.dart';
import 'package:adda_time/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:adda_time/presentation/design_system/colors.dart';
import 'package:adda_time/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:adda_time/presentation/design_system/widgets/custom_text.dart';
import 'package:adda_time/presentation/views/chat/widgets/chat_view_body.dart';
import 'package:adda_time/presentation/views/call/video_call_view.dart';
import 'package:adda_time/presentation/views/call/voice_call_view.dart';
import 'package:adda_time/core/services/chat_preferences_service.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.channel});

  final Channel channel;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    _markChannelAsRead();
  }

  void _markChannelAsRead() {
    widget.channel.markRead();
  }

  void _startVideoCall(User otherUser) {
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;
    final currentUserName = context.read<AuthSessionCubit>().state.authUser.userName;
    final callID = '${widget.channel.id}_video';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallView(
          callID: callID,
          userName: currentUserName ?? currentUserId,
          userID: currentUserId,
        ),
      ),
    );
  }

  void _startVoiceCall(User otherUser) {
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;
    final currentUserName = context.read<AuthSessionCubit>().state.authUser.userName;
    final callID = '${widget.channel.id}_voice';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallView(
          callID: callID,
          userName: currentUserName ?? currentUserId,
          userID: currentUserId,
        ),
      ),
    );
  }

  void _showChatOptionsMenu(BuildContext context, User? otherUser) {
    final prefs = ChatPreferencesService.instance;
    final channelId = widget.channel.id!;
    final channelMembers = widget.channel.state?.members ?? [];
    final isOneToOneChat = channelMembers.length == 2;

    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FutureBuilder<Map<String, bool>>(
        future: Future.wait([
          prefs.isChatPinned(channelId),
          prefs.isChatArchived(channelId),
          prefs.isChatHidden(channelId),
          if (otherUser != null) prefs.isUserBlocked(otherUser.id) else Future.value(false),
        ]).then((results) => {
          'isPinned': results[0],
          'isArchived': results[1],
          'isHidden': results[2],
          'isBlocked': results.length > 3 ? results[3] : false,
        },),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CustomProgressIndicator());
          }

          final isPinned = snapshot.data!['isPinned'] ?? false;
          final isArchived = snapshot.data!['isArchived'] ?? false;
          final isHidden = snapshot.data!['isHidden'] ?? false;
          final isBlocked = snapshot.data!['isBlocked'] ?? false;

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: customGreyColor300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptionTile(
                  context,
                  icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  title: isPinned ? 'Unpin Chat' : 'Pin Chat',
                  onTap: () async {
                    await prefs.togglePinChat(channelId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(
                            text: isPinned ? 'Chat unpinned' : 'Chat pinned',
                            color: white,
                          ),
                          backgroundColor: customIndigoColor,
                        ),
                      );
                    }
                  },
                ),
                _buildOptionTile(
                  context,
                  icon: isArchived ? Icons.unarchive : Icons.archive_outlined,
                  title: isArchived ? 'Unarchive Chat' : 'Archive Chat',
                  onTap: () async {
                    await prefs.toggleArchiveChat(channelId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.go(RouterEnum.dashboardView.routeName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(
                            text: isArchived ? 'Chat unarchived' : 'Chat archived',
                            color: white,
                          ),
                          backgroundColor: customIndigoColor,
                        ),
                      );
                    }
                  },
                ),
                _buildOptionTile(
                  context,
                  icon: isHidden ? Icons.visibility : Icons.visibility_off_outlined,
                  title: isHidden ? 'Unhide Chat' : 'Hide Chat',
                  onTap: () async {
                    if (!isHidden) {
                      // Check if password is set
                      final hasPassword = await prefs.hasHiddenChatPassword();
                      if (!hasPassword && context.mounted) {
                        Navigator.pop(context);
                        _showSetPasswordDialog(context);
                        return;
                      }
                    }
                    
                    await prefs.toggleHideChat(channelId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.go(RouterEnum.dashboardView.routeName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(
                            text: isHidden ? 'Chat unhidden' : 'Chat hidden',
                            color: white,
                          ),
                          backgroundColor: customIndigoColor,
                        ),
                      );
                    }
                  },
                ),
                if (isOneToOneChat && otherUser != null)
                  _buildOptionTile(
                    context,
                    icon: isBlocked ? Icons.block : Icons.block_outlined,
                    title: isBlocked ? 'Unblock User' : 'Block User',
                    onTap: () async {
                      Navigator.pop(context);
                      _showBlockConfirmationDialog(context, otherUser, isBlocked);
                    },
                  ),
                _buildOptionTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Delete Chat',
                  iconColor: dangerColor,
                  titleColor: dangerColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmationDialog(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? customGreyColor800),
      title: CustomText(
        text: title,
        fontSize: 16,
        color: titleColor ?? customGreyColor800,
      ),
      onTap: onTap,
    );
  }

  void _showSetPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Set Password', fontSize: 18, fontWeight: FontWeight.w600),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(
                text: 'Set a password to protect your hidden chats',
                fontSize: 14,
                color: customGreyColor600,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 4) {
                    return 'Password must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText(text: 'Cancel', color: customGreyColor600),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await ChatPreferencesService.instance.setHiddenChatPassword(passwordController.text);
                await ChatPreferencesService.instance.toggleHideChat(widget.channel.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go(RouterEnum.dashboardView.routeName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: CustomText(text: 'Chat hidden successfully', color: white),
                      backgroundColor: customIndigoColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: customIndigoColor),
            child: const CustomText(text: 'Set Password', color: white),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmationDialog(BuildContext context, User user, bool isBlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: isBlocked ? 'Unblock User' : 'Block User',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          text: isBlocked
              ? 'Are you sure you want to unblock ${user.name}?'
              : 'Are you sure you want to block ${user.name}? You will not receive messages from this user.',
          fontSize: 14,
          color: customGreyColor600,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText(text: 'Cancel', color: customGreyColor600),
          ),
          ElevatedButton(
            onPressed: () async {
              await ChatPreferencesService.instance.toggleBlockUser(user.id);
              if (context.mounted) {
                Navigator.pop(context);
                context.go(RouterEnum.dashboardView.routeName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: CustomText(
                      text: isBlocked ? 'User unblocked' : 'User blocked',
                      color: white,
                    ),
                    backgroundColor: customIndigoColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? customIndigoColor : dangerColor,
            ),
            child: CustomText(text: isBlocked ? 'Unblock' : 'Block', color: white),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Delete Chat', fontSize: 18, fontWeight: FontWeight.w600),
        content: const CustomText(
          text: 'Are you sure you want to delete this chat? This action cannot be undone.',
          fontSize: 14,
          color: customGreyColor600,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText(text: 'Cancel', color: customGreyColor600),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete from Stream Chat
                await widget.channel.delete();
                // Delete from local preferences
                await ChatPreferencesService.instance.deleteChat(widget.channel.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go(RouterEnum.dashboardView.routeName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: CustomText(text: 'Chat deleted successfully', color: white),
                      backgroundColor: customIndigoColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: CustomText(text: 'Failed to delete chat: $e', color: white),
                      backgroundColor: dangerColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            child: const CustomText(text: 'Delete', color: white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: widget.channel,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: const ChatViewBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;
    final channelMembers = widget.channel.state?.members ?? [];
    final isOneToOneChat = channelMembers.length == 2;

    User? otherUser;
    if (isOneToOneChat) {
      try {
        otherUser = channelMembers.firstWhere((member) => member.userId != currentUserId).user;
      } catch (e) {
        // No other user found
      }
    }

    final displayName =
        isOneToOneChat && otherUser != null ? otherUser.name : widget.channel.name ?? localization?.unnamedGroup;

    final imageUrl = isOneToOneChat && otherUser != null ? otherUser.image : widget.channel.image;

    return AppBar(
      backgroundColor: white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: customGreyColor800),
        onPressed: () => context.go(RouterEnum.dashboardView.routeName),
      ),
      title: Row(
        children: [
          _buildAvatar(imageUrl, isOneToOneChat),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: displayName ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOneToOneChat && otherUser?.online == true)
                  CustomText(text: localization?.online ?? '', fontSize: 12, color: successColor),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isOneToOneChat && otherUser != null) ...[
          IconButton(
            icon: const Icon(Icons.videocam, color: customGreyColor800),
            onPressed: () => _startVideoCall(otherUser!),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: customGreyColor800),
            onPressed: () => _startVoiceCall(otherUser!),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.more_vert, color: customGreyColor800),
          onPressed: () => _showChatOptionsMenu(context, otherUser),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? imageUrl, bool isOneToOneChat) {
    const double avatarSize = 36;

    final Widget defaultAvatar = CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: customIndigoColor.withValues(alpha: 0.1),
      child: Icon(
        isOneToOneChat ? Icons.person : Icons.group,
        color: customIndigoColor,
        size: avatarSize / 2.5,
      ),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return defaultAvatar;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: customGreyColor200,
        child: CustomProgressIndicator(
          size: 20,
          progressIndicatorColor: customIndigoColor,
        ),
      ),
      errorWidget: (context, url, error) => defaultAvatar,
    );
  }
}
