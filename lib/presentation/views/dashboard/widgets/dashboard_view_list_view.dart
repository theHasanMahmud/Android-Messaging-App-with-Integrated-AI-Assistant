import 'package:flutter/material.dart';
import 'package:bondhu/core/services/chat_preferences_service.dart';
import 'package:bondhu/presentation/views/dashboard/widgets/dashboard_view_error_widget.dart';
import 'package:bondhu/presentation/views/dashboard/widgets/dashboard_view_loading_widget.dart';
import 'package:bondhu/presentation/views/dashboard/widgets/dashboard_view_list_item_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A widget for displaying a list of channels with search functionality
class DashboardViewListView extends StatefulWidget {
  const DashboardViewListView({
    super.key,
    required this.controller,
    required this.searchText,
    required this.onChannelTap,
    required this.onSearchResultsChanged,
  });

  /// The controller for the Stream channel list
  final StreamChannelListController controller;

  /// Current search query text
  final String searchText;

  /// Callback when a channel is tapped
  final void Function(Channel) onChannelTap;

  /// Callback to notify when search results change
  final Function(bool hasNoResults) onSearchResultsChanged;

  @override
  State<DashboardViewListView> createState() => _DashboardViewListViewState();
}

class _DashboardViewListViewState extends State<DashboardViewListView> {
  final _prefs = ChatPreferencesService.instance;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<Map<String, List<String>>>(
        future: Future.wait([
          _prefs.getHiddenChats(),
          _prefs.getArchivedChats(),
          _prefs.getPinnedChats(),
        ]).then((results) => {
          'hidden': results[0],
          'archived': results[1],
          'pinned': results[2],
        },),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const DashboardViewLoadingWidget();
          }

          final hiddenChats = snapshot.data!['hidden']!;
          final archivedChats = snapshot.data!['archived']!;
          final pinnedChats = snapshot.data!['pinned']!;

          return StreamChannelListView(
            padding: const EdgeInsets.only(top: 8),
            controller: widget.controller,
            onChannelTap: widget.onChannelTap,
            errorBuilder: (_, __) => DashboardViewErrorWidget(onRetry: () => widget.controller.refresh()),
            loadingBuilder: (_) => const DashboardViewLoadingWidget(),
            itemBuilder: (context, channels, index, defaultWidget) {
              // Filter channels
              final visibleChannels = channels.where((channel) {
                final cid = channel.cid;
                return !hiddenChats.contains(cid) && !archivedChats.contains(cid);
              }).toList();

              // Sort: pinned chats first, then by last message
              visibleChannels.sort((a, b) {
                final aPinned = pinnedChats.contains(a.cid);
                final bPinned = pinnedChats.contains(b.cid);

                if (aPinned && !bPinned) return -1;
                if (!aPinned && bPinned) return 1;

                // Both pinned or both not pinned, sort by last message
                final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bTime.compareTo(aTime);
              });

              if (index >= visibleChannels.length) {
                return const SizedBox.shrink();
              }

              final channel = visibleChannels[index];
              final isPinned = pinnedChats.contains(channel.cid);

              return DashboardViewListItemBuilder(
                channels: visibleChannels,
                index: index,
                defaultWidget: defaultWidget.copyWith(channel: channel),
                searchText: widget.searchText,
                onSearchResultsChanged: widget.onSearchResultsChanged,
                isPinned: isPinned,
              );
            },
          );
        },
      ),
    );
  }
}
