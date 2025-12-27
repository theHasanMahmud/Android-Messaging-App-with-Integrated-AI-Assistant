import 'package:flutter/material.dart';
import 'package:bondhu/presentation/design_system/colors.dart';
import 'package:bondhu/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:bondhu/presentation/design_system/widgets/custom_text.dart';
import 'package:bondhu/presentation/l10n/app_localizations.dart';
import 'package:bondhu/presentation/views/chat/widgets/chat_view_thread_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:bondhu/core/interfaces/i_chat_repository.dart';

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: StreamMessageListView(
            threadBuilder: (_, parentMessage) {
              if (parentMessage == null) return const SizedBox.shrink();
              return ChatViewThreadWidget(parent: parentMessage);
            },
            messageBuilder: (context, details, messages, defaultMessage) {
              final chatRepo = GetIt.instance<IChatRepository>();

              return FutureBuilder<String?>(
                future: chatRepo.tryDecryptMessage(details.message),
                builder: (context, snapshot) {
                  final decrypted = snapshot.data;
                  final displayText = (decrypted != null && decrypted.isNotEmpty)
                      ? decrypted
                      : (details.message.text ?? '');

                  return defaultMessage.copyWith(
                    showUserAvatar: DisplayWidget.show,
                    showTimestamp: true,
                    message: defaultMessage.message.copyWith(text: displayText),
                  );
                },
              );
            },
            emptyBuilder: (context) => Center(
              child: CustomText(text: localization?.sendMessageToStartConversation ?? ''),
            ),
            loadingBuilder: (context) => const Center(
              child: CustomProgressIndicator(progressIndicatorColor: customIndigoColor),
            ),
          ),
        ),
        const StreamMessageInput(
          autoCorrect: false,
          activeSendIcon: Icon(Icons.send, size: 30, color: customIndigoColor),
          idleSendIcon: Icon(Icons.send, size: 30, color: customGreyColor600),
        ),
      ],
    );
  }
}
