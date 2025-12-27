import 'package:flutter/material.dart';
import 'package:adda_time/core/services/chat_preferences_service.dart';
import 'package:adda_time/presentation/design_system/colors.dart';
import 'package:adda_time/presentation/design_system/widgets/custom_text.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ProfileViewPrivacyCard extends StatefulWidget {
  const ProfileViewPrivacyCard({super.key});

  @override
  State<ProfileViewPrivacyCard> createState() => _ProfileViewPrivacyCardState();
}

class _ProfileViewPrivacyCardState extends State<ProfileViewPrivacyCard> {
  final _prefs = ChatPreferencesService.instance;
  bool _isOnlineStatusHidden = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hideStatus = await _prefs.isOnlineStatusHidden();
    setState(() {
      _isOnlineStatusHidden = hideStatus;
      _isLoading = false;
    });
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _isOnlineStatusHidden = value);
    await _prefs.setOnlineStatusVisibility(value);

    // Update Stream Chat presence
    try {
      final client = StreamChat.of(context).client;
      final currentUser = client.state.currentUser;
      if (currentUser != null) {
        // Toggle connection to simulate invisible/visible status
        if (value) {
          client.closeConnection();
        } else {
          client.openConnection();
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: value
                  ? 'You will appear offline to others'
                  : 'You will appear online to others',
              color: white,
            ),
            backgroundColor: customIndigoColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: 'Failed to update online status: $e',
              color: white,
            ),
            backgroundColor: dangerColor,
            duration: const Duration(seconds: 3),
          ),
        );
        // Revert the toggle if failed
        setState(() => _isOnlineStatusHidden = !value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: customGreyColor300.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: customIndigoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: customIndigoColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: CustomText(
                  text: 'Privacy Settings',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: customGreyColor200),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: 'Hide Online Status',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: _isOnlineStatusHidden
                          ? 'You appear offline to others'
                          : 'Others can see when you\'re online',
                      fontSize: 13,
                      color: customGreyColor600,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isOnlineStatusHidden,
                onChanged: _toggleOnlineStatus,
                activeTrackColor: customIndigoColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
