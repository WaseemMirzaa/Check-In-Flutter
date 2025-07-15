// Example implementation for Players page
import 'package:check_in/Services/review_service.dart';
import 'package:check_in/ui/widgets/review_widgets.dart';
import 'package:flutter/material.dart';

class PlayerProfileExample extends StatefulWidget {
  final String playerId;
  final String playerName;
  final String playerLocation;
  final String playerImageUrl;
  final bool isPremium;

  const PlayerProfileExample({
    super.key,
    required this.playerId,
    required this.playerName,
    required this.playerLocation,
    required this.playerImageUrl,
    required this.isPremium,
  });

  @override
  State<PlayerProfileExample> createState() => _PlayerProfileExampleState();
}

class _PlayerProfileExampleState extends State<PlayerProfileExample> {
  late Future<Map<String, dynamic>> playerStats;

  @override
  void initState() {
    super.initState();
    playerStats = _getPlayerStats();
  }

  Future<Map<String, dynamic>> _getPlayerStats() async {
    return ReviewService.getReviewStats(
      targetId: widget.playerId,
      reviewType: ReviewType.player,
    );
  }

  void _refreshPlayerStats() {
    setState(() {
      playerStats = _getPlayerStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playerName),
      ),
      body: Column(
        children: [
          // Player Info Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.playerImageUrl.isNotEmpty
                      ? NetworkImage(widget.playerImageUrl)
                      : null,
                  child: widget.playerImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.playerName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.playerLocation,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Player Review Stats
          ReviewStatsWidget(
            targetId: widget.playerId,
            reviewType: ReviewType.player,
          ),

          // Spacer to push button to bottom
          const Spacer(),

          // Rate Player Button
          ReviewButton(
            targetId: widget.playerId,
            targetName: widget.playerName,
            targetLocation: widget.playerLocation,
            targetImageUrl: widget.playerImageUrl,
            reviewType: ReviewType.player,
            isPremium: widget.isPremium,
            buttonText: "Rate This Player",
            onReviewSubmitted: _refreshPlayerStats,
          ),
        ],
      ),
    );
  }
}

/*
HOW TO USE THE DYNAMIC REVIEW SYSTEM:

1. For Courts (as updated in reviews.dart):
   ReviewService.showReviewDialog(
     context: context,
     name: courtName,
     location: courtLocation,
     imageUrl: courtImageUrl,
     targetId: courtId,
     reviewType: ReviewType.court,
     onReviewSubmitted: () => _refreshData(),
   );

2. For Players:
   ReviewService.showReviewDialog(
     context: context,
     name: playerName,
     location: playerLocation,
     imageUrl: playerImageUrl,
     targetId: playerId,
     reviewType: ReviewType.player,
     onReviewSubmitted: () => _refreshPlayerData(),
   );

3. Get Review Stats:
   // For Courts
   final courtStats = await ReviewService.getReviewStats(
     targetId: courtId,
     reviewType: ReviewType.court,
   );

   // For Players
   final playerStats = await ReviewService.getReviewStats(
     targetId: playerId,
     reviewType: ReviewType.player,
   );

4. Use Review Widgets:
   // Review button
   ReviewButton(
     targetId: playerId,
     targetName: playerName,
     targetLocation: playerLocation,
     targetImageUrl: playerImageUrl,
     reviewType: ReviewType.player,
     buttonText: "Rate This Player",
     onReviewSubmitted: () => refreshData(),
   )

   // Review stats display
   ReviewStatsWidget(
     targetId: playerId,
     reviewType: ReviewType.player,
   )
*/
