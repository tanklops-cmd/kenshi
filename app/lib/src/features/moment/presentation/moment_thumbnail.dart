import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';

class MomentThumbnail extends StatelessWidget {
  const MomentThumbnail({required this.moment, this.height = 220, super.key});

  final Moment moment;
  final double height;

  @override
  Widget build(BuildContext context) {
    final file = File(moment.localPath);
    if (moment.type == MomentType.photo && file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        moment.type == MomentType.video
            ? Icons.videocam_outlined
            : Icons.image_outlined,
        size: 56,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
