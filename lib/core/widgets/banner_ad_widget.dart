import 'package:flutter/material.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      child: Center(child: Text('Ads Disabled')),
    );
  }
}
