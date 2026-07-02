import 'package:flutter/material.dart';
import 'package:hood_officials/screens/post/officials_post_container.dart';

class OfficialPostScreen extends StatelessWidget {
  const OfficialPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OfficialsPostContainer(
      initialTab: 1,
    );
  }
}
