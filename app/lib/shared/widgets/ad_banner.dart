import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/ad_config.dart';
import '../../models/user_model.dart';

/// Banner ad widget. Automatically hidden for premium users.
class AuraBannerAd extends StatefulWidget {
  final SubscriptionTier tier;

  const AuraBannerAd({super.key, required this.tier});

  @override
  State<AuraBannerAd> createState() => _AuraBannerAdState();
}

class _AuraBannerAdState extends State<AuraBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.tier == SubscriptionTier.free) {
      _ad = BannerAd(
        adUnitId: AdConfig.bannerAdUnit,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) setState(() => _isLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _ad = null;
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tier != SubscriptionTier.free || !_isLoaded || _ad == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
