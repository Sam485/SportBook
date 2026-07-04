import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/widgets/common/map_picker_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isAvatarLoading = false;
  String? _uploadedAvatarUrl;
  bool _isDisposed = false;

  // Location variables
  double? _selectedLat;
  double? _selectedLng;
  String _selectedAddress = '';

  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = getIt<UserService>();

    final user = _userService.currentUser;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');

    // Initialize location from user data
    if (user?.lat != null && user?.lng != null) {
      _selectedLat = user!.lat;
      _selectedLng = user.lng;
      _selectedAddress = user.location ?? '';
    }

    // Listen to user service changes
    _userService.addListener(_onUserServiceChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userService.removeListener(_onUserServiceChanged);
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onUserServiceChanged() {
    if (!_isDisposed && mounted) {
      final user = _userService.currentUser;
      if (user != null) {
        setState(() {
          _uploadedAvatarUrl = user.avatarUrl;
        });
      }
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    // Prevent multiple uploads
    if (_isAvatarLoading) return;

    setState(() {
      _isAvatarLoading = true;
      // Show the selected image immediately for better UX
      _selectedImage = imageFile;
    });

    try {
      // Upload avatar
      final updatedUser = await _userService.updateAvatar(imageFile);

      if (!_isDisposed && mounted) {
        setState(() {
          _uploadedAvatarUrl = updatedUser.avatarUrl;
          _selectedImage = null;
          _isAvatarLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'avatar_update_failed'.tr(context)}: $errorMessage',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _selectedImage = null;
          _isAvatarLoading = false;
        });
      }
    }
  }

  // FIXED: This method now properly handles image picking
  Future<void> _pickImage() async {
    if (_isAvatarLoading) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        final file = File(image.path);
        await _uploadAvatar(file);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // FIXED: This method now properly handles taking a photo
  Future<void> _takePhoto() async {
    if (_isAvatarLoading) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        final file = File(image.path);
        await _uploadAvatar(file);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to take photo: $e',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // FIXED: This method now properly shows the image picker options
  Future<void> _showImagePickerDialog() async {
    if (_isAvatarLoading) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show custom bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub)
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'choose_photo'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.kAccent,
                  ),
                ),
                title: Text(
                  'choose_from_library'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppTheme.kAccent,
                  ),
                ),
                title: Text(
                  'take_a_photo'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_uploadedAvatarUrl != null || _selectedImage != null)
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.red),
                  ),
                  title: Text(
                    'remove_photo'.tr(context),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Method to remove avatar (placeholder)
  Future<void> _removeAvatar() async {
    // You would need an API endpoint to remove avatar
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Remove avatar feature coming soon',
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: MapPickerScreen(
            initialLat: _selectedLat,
            initialLng: _selectedLng,
            initialLabel: _selectedAddress,
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _selectedAddress = result;
        _locationController.text = result;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'fill_all_fields'.tr(context),
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateDto = UpdateDto(
        fullName: _nameController.text.trim(),
        location: _locationController.text.trim(),
        lat: _selectedLat ?? 0.0,
        lng: _selectedLng ?? 0.0,
      );

      await _userService.updateProfile(updateDto);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'update_failed'.tr(context)}: $errorMessage',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _userService.currentUser;

    // Determine which avatar to show
    String? avatarUrl;
    if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty) {
      avatarUrl = _uploadedAvatarUrl;
    } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      avatarUrl = user.avatarUrl;
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'edit_profile'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.kAccent,
                    ),
                  )
                : Text(
                    'save'.tr(context),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.kAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _profileImage(avatarUrl: avatarUrl, isDark: isDark),
          ),
          SliverToBoxAdapter(child: _textFields(isDark: isDark)),
          SliverToBoxAdapter(child: _saveButton(isDark: isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _profileImage({required String? avatarUrl, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: GestureDetector(
          onTap: _isAvatarLoading ? null : _showImagePickerDialog,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.kAccent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: _isAvatarLoading
                      ? Container(
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.kAccent,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (_, _, _) => Container(
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub,
                            ),
                          ),
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDark
                                  ? AppTheme.kCardAlt
                                  : AppTheme.kLightCardAlt,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.kAccent,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: isDark
                                ? AppTheme.kTextSub
                                : AppTheme.kLightTextSub,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: _isAvatarLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.black,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFields({required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Name Field
          _buildTextField(
            controller: _nameController,
            icon: Icons.person_outline,
            label: 'full_name'.tr(context),
            keyboardType: TextInputType.text,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Location Field with Picker
          _buildLocationField(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildLocationField({required bool isDark}) {
    return GestureDetector(
      onTap: _openLocationPicker,
      child: AbsorbPointer(
        child: TextField(
          controller: _locationController,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 16,
          ),
          keyboardType: TextInputType.text,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'location'.tr(context),
            labelStyle: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
            suffixIcon: Icon(Icons.edit_location, color: AppTheme.kAccent),
            hintText: 'tap_to_select_location'.tr(context),
            hintStyle: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.red.shade300,
              fontSize: 12,
            ),
            filled: true,
            fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required TextInputType keyboardType,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        color: isDark ? Colors.white : AppTheme.kLightText,
        fontSize: 16,
      ),
      keyboardType: keyboardType,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        ),
        hintStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: Colors.red.shade300,
          fontSize: 12,
        ),
        filled: true,
        fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
      ),
    );
  }

  Widget _saveButton({required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.kAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Text(
                  'save_changes'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
