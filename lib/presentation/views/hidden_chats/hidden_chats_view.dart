import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondhu/core/services/chat_preferences_service.dart';
import 'package:bondhu/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:bondhu/presentation/design_system/colors.dart';
import 'package:bondhu/presentation/design_system/widgets/custom_text.dart';
import 'package:bondhu/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:bondhu/presentation/views/chat/chat_view.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class HiddenChatsView extends StatefulWidget {
  const HiddenChatsView({super.key});

  @override
  State<HiddenChatsView> createState() => _HiddenChatsViewState();
}

class _HiddenChatsViewState extends State<HiddenChatsView> {
  final _prefs = ChatPreferencesService.instance;
  final _passwordController = TextEditingController();
  bool _isUnlocked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    setState(() => _isLoading = true);

    final isValid = await _prefs.verifyHiddenChatPassword(_passwordController.text);

    setState(() => _isLoading = false);

    if (isValid) {
      setState(() => _isUnlocked = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomText(text: 'Incorrect password', color: white),
            backgroundColor: dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Hidden Chats',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: customGreyColor800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isUnlocked ? _buildHiddenChatsList() : _buildPasswordPrompt(),
    );
  }

  Widget _buildPasswordPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: customIndigoColor),
            const SizedBox(height: 24),
            const CustomText(
              text: 'Enter Password',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: 'Enter your password to view hidden chats',
              fontSize: 14,
              color: customGreyColor600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: customGreyColor50,
              ),
              onSubmitted: (_) => _verifyPassword(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customIndigoColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CustomProgressIndicator(
                        size: 24,
                        progressIndicatorColor: white,
                      )
                    : const CustomText(
                        text: 'Unlock',
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenChatsList() {
    final client = StreamChat.of(context).client;
    final currentUser = context.read<AuthSessionCubit>().state.authUser;

    return FutureBuilder<List<String>>(
      future: _prefs.getHiddenChats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CustomProgressIndicator());
        }

        final hiddenChats = snapshot.data!;

        if (hiddenChats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility_off_outlined, size: 64, color: customGreyColor300),
                SizedBox(height: 16),
                CustomText(
                  text: 'No hidden chats',
                  fontSize: 16,
                  color: customGreyColor600,
                ),
              ],
            ),
          );
        }

        return StreamChannelListView(
          controller: StreamChannelListController(
            client: client,
            filter: Filter.and([
              Filter.in_('cid', hiddenChats),
              Filter.in_('members', [currentUser.id]),
            ]),
            channelStateSort: const [SortOption.desc('last_message_at')],
          ),
          itemBuilder: (context, items, index, defaultWidget) {
            return StreamChannelListTile(
              channel: items[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatView(channel: items[index]),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.visibility, color: customIndigoColor),
                onPressed: () async {
                  await _prefs.toggleHideChat(items[index].id!);
                  setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: CustomText(text: 'Chat unhidden', color: white),
                        backgroundColor: customIndigoColor,
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
