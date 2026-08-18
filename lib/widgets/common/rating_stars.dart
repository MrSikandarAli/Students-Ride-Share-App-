import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Read-only star rating used on ride cards and profiles.
class RatingStarsDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;

  const RatingStarsDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.accent, size: size),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text('($reviewCount)', style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}

/// Interactive star input used on the "rate this ride" screen.
class RatingStarsInput extends StatelessWidget {
  final double initialRating;
  final void Function(double) onRatingUpdate;
  final double size;

  const RatingStarsInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingUpdate,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      itemCount: 5,
      itemSize: size,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
      onRatingUpdate: onRatingUpdate,
    );
  }
}
