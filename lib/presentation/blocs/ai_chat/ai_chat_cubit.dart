import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bondhu/data/remote/ai_api_client.dart';

part 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit({required AiApiClient apiClient})
      : _apiClient = apiClient,
        super(AiChatState.initial());

  final AiApiClient _apiClient;

  Future<void> sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;
    emit(state.copyWith(isLoading: true));
    try {
      final resp = await _apiClient.sendMessage(prompt);
      emit(state.copyWith(isLoading: false, lastResponse: resp));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
