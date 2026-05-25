
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ad_service.dart';
import 'glass_container.dart';

/// "Watch ad for +1 generation" prompt widget.
/// Shows remaining generations and a CTA to watch rewarded video.
class RewardedPrompt extends StatefulWidget {
  final int remaining;
  final VoidCallback onRewardEarned;

  const RewardedPrompt({
    super.key,
    required this.remaining,
    required this.onRewardEarned,
  });

  @override
  State<RewardedPrompt> createState() => _RewardedPromptState();
}

class _RewardedPromptState extends State<RewardedPrompt> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final adService = AdService();

    if (!adService.canWatchRewarded) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      borderColor: AppColors.neonOrange.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🎁', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free Generations Used',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.remaining} remaining today • Watch ad for +1',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading
                ? null
                : () async {
                    HapticFeedback.mediumImpact();
                    setState(() => _isLoading = true);
                    final earned =
                        await adService.showRewardedForExtraGeneration();
                    setState(() => _isLoading = false);
                    if (earned) {
                      widget.onRewardEarned();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('+1 free generation earned! 🎉'),
                            backgroundColor: AppColors.neonGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFFAB00)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonOrange.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill, size: 16, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          '+1 Free',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
