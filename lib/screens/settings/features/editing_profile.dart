import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/common/image_picker_bottom_sheet.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final UserService userService;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.userService,
  });

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

  // Location variables
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLocationPickerOpen = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _locationController = TextEditingController(
      text: widget.user.location ?? '',
    );

    // Initialize location from user data
    if (widget.user.lat != null && widget.user.lng != null) {
      _selectedLocation = LatLng(widget.user.lat!, widget.user.lng!);
      _selectedAddress = widget.user.location ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _uploadAvatar(File imageFile) async {
    setState(() {
      _isAvatarLoading = true;
    });

    try {
      // Upload the avatar and get the URL
      final avatarUrl = await widget.userService.updateAvatar(imageFile);

      setState(() {
        _uploadedAvatarUrl = avatarUrl.avatarUrl;
        _selectedImage = null; // Clear temp selected image
        _isAvatarLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('avatar_updated_successfully'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'avatar_update_failed'.tr(context)}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isAvatarLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation(MapController controller) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      await _updateAddressFromCoordinates();

      // Move map
      controller.move(_selectedLocation!, 15);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAddressFromCoordinates() async {
    if (_selectedLocation == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          _selectedAddress = address;
          _locationController.text = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Future<void> _searchLocation(String query, MapController controller) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _selectedLocation = LatLng(location.latitude, location.longitude);
        });

        await _updateAddressFromCoordinates();

        // Move map
        controller.move(_selectedLocation!, 15);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openLocationPicker() async {
    setState(() {
      _isLocationPickerOpen = true;
    });

    // Create a new MapController for the bottom sheet
    final mapController = MapController();

    // Set initial location if available
    if (_selectedLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.move(_selectedLocation!, 13);
      });
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.kBg
                      : AppTheme.kLightBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: (query) async {
                                await _searchLocation(query, mapController);
                                setModalState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: 'search_location'.tr(context),
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.kCard
                                    : AppTheme.kLightCard,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              await _getCurrentLocation(mapController);
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.my_location),
                            tooltip: 'current_location'.tr(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter:
                              _selectedLocation ?? const LatLng(0, 0),
                          initialZoom: 13,
                          onTap: (tapPosition, point) {
                            setModalState(() {
                              _selectedLocation = point;
                            });
                            _updateAddressFromCoordinates();
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sportbook.app',
                          ),
                          MarkerLayer(
                            markers: [
                              if (_selectedLocation != null)
                                Marker(
                                  point: _selectedLocation!,
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedAddress.isNotEmpty
                                  ? _selectedAddress
                                  : 'tap_on_map_to_select_location'.tr(context),
                              style: TextStyle(
                                color: _selectedAddress.isNotEmpty
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _selectedLocation != null
                                ? () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isLocationPickerOpen = false;
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.kAccent,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('confirm'.tr(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('fill_all_fields'.tr(context))));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update profile data
      final updateDto = UpdateDto(
        fullName: _nameController.text,
        location: _locationController.text,
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
      );

      final updatedUser = await widget.userService.updateProfile(updateDto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile_updated_successfully'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'update_failed'.tr(context)}: $e'),
            backgroundColor: Colors.red,
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final file = File(image.path);
      setState(() {
        _selectedImage = file;
      });
      // Upload immediately
      await _uploadAvatar(file);
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      final file = File(image.path);
      setState(() {
        _selectedImage = file;
      });
      // Upload immediately
      await _uploadAvatar(file);
    }
  }

  Future<void> _showImagePickerDialog() async {
    final file = await ImagePickerBottomSheet.show(context);
    if (file != null) {
      setState(() => _selectedImage = file);
      // Upload immediately
      await _uploadAvatar(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          SliverToBoxAdapter(child: _profileImage()),
          SliverToBoxAdapter(child: _textFields()),
          SliverToBoxAdapter(child: _saveButton()),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _profileImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine which avatar to show
    String? avatarUrl;
    if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty) {
      avatarUrl = _uploadedAvatarUrl;
    } else if (widget.user.avatarUrl != null &&
        widget.user.avatarUrl!.isNotEmpty) {
      avatarUrl = widget.user.avatarUrl;
    }

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
                          errorBuilder: (_, __, ___) => Container(
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

  Widget _textFields() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      onTap: _isLocationPickerOpen ? null : _openLocationPicker,
      child: AbsorbPointer(
        child: TextField(
          controller: _locationController,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 16,
          ),
          keyboardType: TextInputType.text,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'location'.tr(context),
            labelStyle: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
            suffixIcon: Icon(Icons.edit_location, color: AppTheme.kAccent),
            hintText: 'tap_to_select_location'.tr(context),
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
        color: isDark ? Colors.white : AppTheme.kLightText,
        fontSize: 16,
      ),
      keyboardType: keyboardType,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
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
        filled: true,
        fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
      ),
    );
  }

  Widget _saveButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
