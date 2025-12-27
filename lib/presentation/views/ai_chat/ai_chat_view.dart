import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:bondhu/data/remote/ai_api_client.dart';
import 'package:bondhu/presentation/blocs/ai_chat/ai_chat_cubit.dart';

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = GetIt.instance<AiApiClient>();

    return BlocProvider(
      create: (_) => AiChatCubit(apiClient: apiClient),
      child: Scaffold(
        appBar: AppBar(title: const Text('AI Chat')),
        body: const _AiChatBody(),
      ),
    );
  }
}

class _AiChatBody extends StatefulWidget {
  const _AiChatBody();

  @override
  State<_AiChatBody> createState() => _AiChatBodyState();
}

class _AiChatBodyState extends State<_AiChatBody> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<AiChatCubit, AiChatState>(builder: (context, state) {
              if (state.isLoading) return const Center(child: CircularProgressIndicator());
              if (state.error != null) return Center(child: Text('Error: ${state.error}'));
              if (state.lastResponse != null) return SingleChildScrollView(child: Text(state.lastResponse!));
              return const Center(child: Text('Send a prompt to start'));
            },),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: _controller),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final prompt = _controller.text;
                  context.read<AiChatCubit>().sendPrompt(prompt);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
