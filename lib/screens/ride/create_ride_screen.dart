import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../models/ride_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/ride/seat_selector.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _departureTime;
  int _seats = 2;
  bool _isSubmitting = false;

  final _locationService = LocationService();
  final _firestoreService = FirestoreService();

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      _departureTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a departure time')),
      );
      return;
    }

    final profile = context.read<AppAuthProvider>().profile;
    if (profile == null) return;

    setState(() => _isSubmitting = true);
    try {
      final startPoint = await _locationService.geocodeAddress(_startController.text);
      final destinationPoint = await _locationService.geocodeAddress(_destinationController.text);

      final ride = RideModel(
        id: '',
        driverId: profile.uid,
        driverName: profile.fullName,
        driverPhotoUrl: profile.photoUrl,
        driverRating: profile.rating,
        startAddress: _startController.text.trim(),
        startPoint: startPoint,
        destinationAddress: _destinationController.text.trim(),
        destinationPoint: destinationPoint,
        departureTime: _departureTime!,
        totalSeats: _seats,
        costPerSeat: double.parse(_costController.text.trim()),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createRide(ride);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride posted! Passengers can now find it.')),
      );
      _formKey.currentState!.reset();
      _startController.clear();
      _destinationController.clear();
      _costController.clear();
      setState(() {
        _departureTime = null;
        _seats = 2;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createRide)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offer a ride to fellow students', style: AppTextStyles.h3),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.startingLocation,
                    controller: _startController,
                    prefixIcon: Icons.trip_origin_rounded,
                    hint: 'e.g. Main Campus Gate',
                    validator: (v) => Validators.required(v, field: 'Starting location'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.destination,
                    controller: _destinationController,
                    prefixIcon: Icons.location_on_outlined,
                    hint: 'e.g. Downtown Station',
                    validator: (v) => Validators.required(v, field: 'Destination'),
                  ),
                  const SizedBox(height: 16),
                  _DepartureTimePicker(
                    departureTime: _departureTime,
                    onTap: _pickDepartureTime,
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.availableSeats, style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 8),
                  SeatSelector(value: _seats, onChanged: (v) => setState(() => _seats = v)),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.costPerSeat,
                    controller: _costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.attach_money_rounded,
                    hint: '5.00',
                    validator: (v) => Validators.positiveNumber(v, field: 'cost'),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: 'Post Ride',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
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

class _DepartureTimePicker extends StatelessWidget {
  final DateTime? departureTime;
  final VoidCallback onTap;

  const _DepartureTimePicker({required this.departureTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.departureTime, style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFA0A3B1)),
                const SizedBox(width: 10),
                Text(
                  departureTime == null
                      ? 'Select date & time'
                      : '${departureTime!.toLocal()}'.split('.').first,
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
