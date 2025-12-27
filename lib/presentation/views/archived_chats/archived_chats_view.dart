import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adda_time/core/services/chat_preferences_service.dart';
import 'package:adda_time/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:adda_time/presentation/design_system/colors.dart';
import 'package:adda_time/presentation/design_system/widgets/custom_text.dart';
import 'package:adda_time/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:adda_time/presentation/views/chat/chat_view.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ArchivedChatsView extends StatefulWidget {
  const ArchivedChatsView({super.key});

  @override
  State<ArchivedChatsView> createState() => _ArchivedChatsViewState();
}

class _ArchivedChatsViewState extends State<ArchivedChatsView> {
  final _prefs = ChatPreferencesService.instance;

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;
    final currentUser = context.read<AuthSessionCubit>().state.authUser;

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Archived Chats',
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
      body: FutureBuilder<List<String>>(
        future: _prefs.getArchivedChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CustomProgressIndicator());
          }

          final archivedChats = snapshot.data!;

          if (archivedChats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 64, color: customGreyColor300),
                  SizedBox(height: 16),
                  CustomText(
                    text: 'No archived chats',
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
                Filter.in_('cid', archivedChats),
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
                  icon: const Icon(Icons.unarchive, color: customIndigoColor),
                  onPressed: () async {
                    await _prefs.toggleArchiveChat(items[index].id!);
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: CustomText(text: 'Chat unarchived', color: white),
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
      ),
    );
  }
}
