import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../models/ride_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/rating_stars.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/ride/ride_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final profile = auth.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  UserAvatar(
                    name: profile.fullName,
                    photoUrl: profile.photoUrl,
                    radius: 44,
                    isVerified: profile.isVerified,
                  ),
                  const SizedBox(height: 14),
                  Text(profile.fullName, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(profile.university, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 10),
                  RatingStarsDisplay(rating: profile.rating, reviewCount: profile.ratingCount, size: 18),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 18, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Text('Student ID: ${profile.studentId}', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textHint,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Rides I Posted'),
                      Tab(text: 'Rides I Joined'),
                    ],
                  ),
                  SizedBox(
                    height: 420,
                    child: TabBarView(
                      children: [
                        _RideListTab(stream: FirestoreService().myPostedRides(profile.uid)),
                        _RideListTab(stream: FirestoreService().myJoinedRides(profile.uid)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Log Out',
                    variant: ButtonVariant.outline,
                    onPressed: () async {
                      await context.read<AppAuthProvider>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RideListTab extends StatelessWidget {
  final Stream<List<RideModel>> stream;
  const _RideListTab({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RideModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rides = snapshot.data!;
        if (rides.isEmpty) {
          return const EmptyState(icon: Icons.directions_car_outlined, title: 'No rides here yet');
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: 12),
          itemCount: rides.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => RideCard(
            ride: rides[i],
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.rideDetails, arguments: rides[i]),
          ),
        );
      },
    );
  }
}
