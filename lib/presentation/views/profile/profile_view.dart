import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adda_time/core/constants/enums/router_enum.dart';
import 'package:adda_time/core/di/dependency_injector.dart';
import 'package:adda_time/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:adda_time/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:adda_time/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:adda_time/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:adda_time/presentation/design_system/colors.dart';
import 'package:adda_time/presentation/views/profile/widgets/profile_view_contact_card.dart';
import 'package:adda_time/presentation/views/profile/widgets/profile_view_cover_card.dart';
import 'package:adda_time/presentation/views/profile/widgets/profile_view_details.dart';
import 'package:adda_time/presentation/views/profile/widgets/profile_view_loading_view.dart';
import 'package:adda_time/presentation/views/profile/widgets/profile_view_sign_out_button.dart';
import 'package:adda_time/presentation/views/profile/widgets/profile_view_status_card.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Displays the user's profile information and account settings.
///
/// This page shows:
/// - User profile information (name, photo, ID)
/// - Account activity and status
/// - Account creation date
/// - Contact information
/// - Sign-out functionality
///
/// It handles both authentication state and Stream Chat connection state
/// to ensure the display of accurate and up-to-date user information.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      listener: _handleAuthStateChanges,
      child: _buildProfileContent(context),
    );
  }

  /// Handles authentication state changes for navigation
  void _handleAuthStateChanges(BuildContext context, AuthSessionState state) {
    if (!state.isLoggedIn) {
      _safelyNavigateToSignIn(context);
    }
  }

  /// Safely navigates to the sign-in view
  void _safelyNavigateToSignIn(BuildContext context) {
    try {
      context.go(RouterEnum.signInView.routeName);
    } catch (e) {
      // Ignore navigation errors
    }
  }

  /// Builds the main profile content with state awareness
  Widget _buildProfileContent(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        return BlocBuilder<ChatSessionCubit, ChatSessionState>(
          builder: (context, chatState) {
            // Always try to show profile even if chat isn't fully ready
            // This prevents blank white screens
            try {
              // Extract user information (works even without chat ready)
              final userInfo = _extractUserInfo(authState, chatState);

              // Build profile UI
              return Container(
                color: backgroundGrey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileViewCoverCard(
                        userName: userInfo.userName,
                        userPhotoUrl: userInfo.photoUrl,
                        userId: userInfo.userId,
                        userPhoneNumber: userInfo.phoneNumber,
                      ),
                      ProfileViewStatusCard(
                        isUserBannedStatus: userInfo.isUserBanned,
                      ),
                      ProfileViewDetails(
                        createdAt: userInfo.createdAt,
                        isUserBannedStatus: userInfo.isUserBanned,
                      ),
                      ProfileViewContactCard(
                        userPhoneNumber: userInfo.phoneNumber,
                        userId: userInfo.userId,
                      ),
                      const ProfileViewSignOutButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            } catch (e) {
              // Fallback: show loading if there's an error
              return const ProfileViewLoadingView();
            }
          },
        );
      },
    );
  }

  /// Checks if Stream Chat is ready for use
  /// Returns true if chat is ready or successfully connected
  bool _isStreamChatReady(BuildContext context, ChatSessionState chatState) {
    // If chat service is already initialized, we're good to go
    if (chatState.isUserCheckedFromChatService) {
      return true;
    }

    // If not initialized, check if Stream Chat is actually connected
    try {
      final client = getIt<StreamChatClient>();
      final isStreamChatConnected = client.state.currentUser != null;

      if (isStreamChatConnected) {
        // Force a sync if client is connected but state doesn't reflect it
        context.read<ChatSessionCubit>().syncWithClientState();
        return true;
      }
    } catch (e) {
      // If error checking connection, return false
    }

    // Chat is not ready
    return false;
  }

  /// Extracts and formats user information from state objects
  ({String userName, String photoUrl, String userId, String phoneNumber, String createdAt, bool isUserBanned})
      _extractUserInfo(AuthSessionState authState, ChatSessionState chatState) {
    // Provide safe defaults for all fields
    final userName = authState.authUser.userName ?? 'User';
    final photoUrl = authState.authUser.photoUrl ?? '';
    final userId = authState.authUser.id.length > 25 
        ? authState.authUser.id.replaceRange(8, 25, '*****')
        : authState.authUser.id;
    final phoneNumber = authState.authUser.phoneNumber;
    
    // Safely get chat user data with fallbacks
    String createdAt = 'N/A';
    bool isUserBanned = false;
    
    try {
      if (chatState.chatUser.createdAt.isNotEmpty) {
        createdAt = chatState.chatUser.createdAt;
      }
      isUserBanned = chatState.chatUser.isUserBanned;
    } catch (e) {
      // Use default values if chat data not available
    }

    return (
      userName: userName,
      photoUrl: photoUrl,
      userId: userId,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      isUserBanned: isUserBanned
    );
  }
}
