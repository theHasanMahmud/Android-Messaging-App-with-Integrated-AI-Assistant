part of 'ai_chat_cubit.dart';

class AiChatState extends Equatable {
  const AiChatState({required this.isLoading, this.lastResponse, this.error});

  final bool isLoading;
  final String? lastResponse;
  final String? error;

  factory AiChatState.initial() => const AiChatState(isLoading: false);

  AiChatState copyWith({bool? isLoading, String? lastResponse, String? error}) {
    return AiChatState(
      isLoading: isLoading ?? this.isLoading,
      lastResponse: lastResponse ?? this.lastResponse,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, lastResponse, error];
}
