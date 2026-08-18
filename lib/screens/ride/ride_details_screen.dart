import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../models/ride_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/rating_stars.dart';
import '../../widgets/common/user_avatar.dart';

class RideDetailsScreen extends StatefulWidget {
  final RideModel ride;
  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final _firestoreService = FirestoreService();
  bool _isJoining = false;

  Future<void> _joinRide() async {
    final profile = context.read<AppAuthProvider>().profile;
    if (profile == null) return;

    setState(() => _isJoining = true);
    try {
      await _firestoreService.joinRide(widget.ride.id, profile.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You joined the ride! Chat with your driver below.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppAuthProvider>().profile;
    final timeFormat = DateFormat('EEEE, MMMM d · h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.rideDetails)),
      body: SafeArea(
        child: StreamBuilder<RideModel>(
          stream: _firestoreService.rideStream(widget.ride.id),
          initialData: widget.ride,
          builder: (context, snapshot) {
            final ride = snapshot.data ?? widget.ride;
            final isDriver = profile?.uid == ride.driverId;
            final hasJoined = profile != null && ride.passengerIds.contains(profile.uid);

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            UserAvatar(
                              name: ride.driverName,
                              photoUrl: ride.driverPhotoUrl,
                              radius: 28,
                              isVerified: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ride.driverName, style: AppTextStyles.h3),
                                  const SizedBox(height: 4),
                                  RatingStarsDisplay(rating: ride.driverRating),
                                ],
                              ),
                            ),
                            if (!isDriver)
                              IconButton.filledTonal(
                                icon: const Icon(Icons.chat_bubble_outline_rounded),
                                onPressed: () {
                                  final chatId = ChatService.chatIdFor(ride.id, profile!.uid);
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.chat,
                                    arguments: {'chatId': chatId, 'otherUserName': ride.driverName},
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(icon: Icons.trip_origin_rounded, label: 'From', value: ride.startAddress),
                            const SizedBox(height: 14),
                            _DetailRow(icon: Icons.location_on_rounded, label: 'To', value: ride.destinationAddress),
                            const SizedBox(height: 14),
                            _DetailRow(icon: Icons.access_time_rounded, label: 'Departs', value: timeFormat.format(ride.departureTime)),
                            const SizedBox(height: 14),
                            _DetailRow(icon: Icons.event_seat_rounded, label: 'Seats', value: '${ride.seatsAvailable} of ${ride.totalSeats} available'),
                            const SizedBox(height: 14),
                            _DetailRow(icon: Icons.attach_money_rounded, label: 'Cost', value: '\$${ride.costPerSeat.toStringAsFixed(2)} per seat'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!isDriver)
                      CustomButton(
                        label: hasJoined ? 'Already Joined' : AppStrings.joinRide,
                        isLoading: _isJoining,
                        onPressed: (hasJoined || ride.isFull) ? null : _joinRide,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('This is your posted ride.')),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
