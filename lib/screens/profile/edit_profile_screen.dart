import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _authService = AuthService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppAuthProvider>().profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = context.read<AppAuthProvider>().profile;
    if (profile == null) return;

    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(profile.uid, {'fullName': _nameController.text.trim()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppAuthProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: UserAvatar(
                      name: profile?.fullName ?? '',
                      photoUrl: profile?.photoUrl,
                      radius: 44,
                      isVerified: profile?.isVerified ?? false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: hook up image_picker + firebase_storage upload.
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Change photo'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => Validators.required(v, field: 'Full name'),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(label: 'Save Changes', isLoading: _isSaving, onPressed: _save),
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
