import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/ride/ride_card.dart';

class SearchRideScreen extends StatefulWidget {
  const SearchRideScreen({super.key});

  @override
  State<SearchRideScreen> createState() => _SearchRideScreenState();
}

class _SearchRideScreenState extends State<SearchRideScreen> {
  final _destinationController = TextEditingController();
  double _radiusKm = 10;
  bool _useNearby = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSearch());
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _runSearch() {
    context.read<RideProvider>().search(
      destinationQuery: _destinationController.text,
      radiusKm: _useNearby ? _radiusKm : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.searchRides)),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Destination',
                controller: _destinationController,
                prefixIcon: Icons.location_on_outlined,
                hint: 'Where are you going?',
                onChanged: (_) => _runSearch(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _useNearby,
                    onChanged: (v) {
                      setState(() => _useNearby = v);
                      _runSearch();
                    },
                  ),
                  const SizedBox(width: 4),
                  Text('Only show nearby rides', style: AppTextStyles.bodyMedium),
                ],
              ),
              if (_useNearby)
                Row(
                  children: [
                    Text('${_radiusKm.round()} km radius', style: AppTextStyles.bodySmall),
                    Expanded(
                      child: Slider(
                        value: _radiusKm,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: (v) => setState(() => _radiusKm = v),
                        onChangeEnd: (_) => _runSearch(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Expanded(child: _buildResults(rideProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(RideProvider rideProvider) {
    if (rideProvider.isLoading) return const LoadingWidget();

    if (rideProvider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Search failed',
        subtitle: rideProvider.errorMessage,
      );
    }

    if (rideProvider.results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: AppStrings.noRidesFound,
        subtitle: 'Try a different destination or widen your search radius.',
      );
    }

    return ListView.separated(
      itemCount: rideProvider.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final ride = rideProvider.results[i];
        return RideCard(
          ride: ride,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.rideDetails, arguments: ride),
        );
      },
    );
  }
}

