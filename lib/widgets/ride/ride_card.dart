import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/ride_model.dart';
import '../common/rating_stars.dart';
import '../common/user_avatar.dart';

/// The single card used everywhere a ride is listed: search results,
/// home feed, "my rides". Keeping one implementation means route
/// styling, seat badges, and price formatting never drift apart.
class RideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onTap;

  const RideCard({super.key, required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('EEE, MMM d · h:mm a');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(name: ride.driverName, photoUrl: ride.driverPhotoUrl, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ride.driverName, style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                        RatingStarsDisplay(rating: ride.driverRating, size: 14),
                      ],
                    ),
                  ),
                  _SeatsBadge(ride: ride),
                ],
              ),
              const SizedBox(height: 14),
              _RouteRow(ride: ride),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Text(timeFormat.format(ride.departureTime), style: AppTextStyles.bodySmall),
                  const Spacer(),
                  Text(
                    '\$${ride.costPerSeat.toStringAsFixed(2)} / seat',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final RideModel ride;
  const _RouteRow({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
            Container(width: 2, height: 28, color: AppColors.divider),
            const Icon(Icons.location_on, color: AppColors.secondary, size: 14),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.startAddress, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 22),
              Text(ride.destinationAddress, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeatsBadge extends StatelessWidget {
  final RideModel ride;
  const _SeatsBadge({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isFull = ride.isFull;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFull ? AppColors.error.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isFull ? 'Full' : '${ride.seatsAvailable} seats',
        style: AppTextStyles.caption.copyWith(
          color: isFull ? AppColors.error : AppColors.secondary,
        ),
      ),
    );
  }
}
