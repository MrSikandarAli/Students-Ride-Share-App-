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
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/ride/ride_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppAuthProvider>().profile;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ResponsiveCenter(
                padding: Responsive.pagePadding(context).copyWith(bottom: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, ${profile?.fullName.split(' ').first ?? 'there'} 👋',
                              style: AppTextStyles.h2),
                          const SizedBox(height: 4),
                          Text('Where are you headed today?', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    UserAvatar(
                      name: profile?.fullName ?? '',
                      photoUrl: profile?.photoUrl,
                      isVerified: profile?.isVerified ?? false,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsiveCenter(
                padding: Responsive.pagePadding(context).copyWith(top: 20, bottom: 0),
                child: _QuickAction(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.searchRide),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsiveCenter(
                padding: Responsive.pagePadding(context).copyWith(top: 24, bottom: 8),
                child: Text('Available rides near you', style: AppTextStyles.h3),
              ),
            ),
            StreamBuilder<List<RideModel>>(
              stream: FirestoreService().streamActiveRides(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: LoadingWidget());
                }
                final rides = snapshot.data ?? [];
                if (rides.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No rides posted yet',
                      subtitle: 'Be the first to post a ride for your route.',
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    padding: Responsive.pagePadding(context).copyWith(top: 0),
                    child: _ResponsiveRideList(rides: rides),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(AppStrings.searchRides,
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Single column on phones, multi-column grid on tablet/desktop.
class _ResponsiveRideList extends StatelessWidget {
  final List<RideModel> rides;
  const _ResponsiveRideList({required this.rides});

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);

    if (columns == 1) {
      return Column(
        children: [
          for (final ride in rides) ...[
            RideCard(
              ride: ride,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.rideDetails, arguments: ride),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rides.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, i) => RideCard(
        ride: rides[i],
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.rideDetails, arguments: rides[i]),
      ),
    );
  }
}
