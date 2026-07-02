import 'package:flutter/material.dart';
import 'package:hood_officials/screens/post/officials_post_container.dart';

class ResolveIssueScreen extends StatelessWidget {
  final String? prefilledIssueId;
  const ResolveIssueScreen({super.key, this.prefilledIssueId});

  @override
  Widget build(BuildContext context) {
    return OfficialsPostContainer(
      initialTab: 0,
      prefilledIssueId: prefilledIssueId,
    );
  }
}
