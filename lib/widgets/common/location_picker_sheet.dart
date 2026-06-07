import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLocating = false;
  String? _errorMsg;
  bool _isPermanentlyDenied = false;

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _errorMsg = null;
      _isPermanentlyDenied = false;
    });

    try {
      // 1. Check current status BEFORE requesting
      PermissionStatus status = await Permission.location.status;

      if (status.isPermanentlyDenied) {
        // Already permanently denied — must go to Settings
        setState(() {
          _isPermanentlyDenied = true;
          _errorMsg = 'Location permission is permanently denied.';
          _isLocating = false;
        });
        return;
      }

      // 2. Not permanently denied — request it (covers first-time & denied-but-askable)
      status = await Permission.location.request();

      if (status.isDenied) {
        // User tapped "Deny" — can still ask again next time
        setState(() {
          _isPermanentlyDenied = false;
          _errorMsg = 'Permission denied. Tap the button to try again.';
          _isLocating = false;
        });
        return;
      }

      if (status.isPermanentlyDenied) {
        // User tapped "Never ask again"
        setState(() {
          _isPermanentlyDenied = true;
          _errorMsg =
              'Permission permanently denied. Open settings to allow it.';
          _isLocating = false;
        });
        return;
      }

      // 3. Permission granted — check if GPS service is on
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMsg = 'Location services are off. Please enable them.';
          _isLocating = false;
        });
        return;
      }

      // 4. Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      // 5. Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      final city = (place.locality?.isNotEmpty == true)
          ? place.locality!
          : (place.subAdministrativeArea?.isNotEmpty == true)
          ? place.subAdministrativeArea!
          : place.administrativeArea ?? 'Unknown';

      if (mounted) Navigator.pop(context, city);
    } catch (e) {
      setState(() {
        _errorMsg = 'Could not get location. Try again.';
        _isLocating = false;
      });
    }
  }

  void _confirmManual() {
    final text = _searchCtrl.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select location',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use your current location or type a city name.',
            style: TextStyle(color: AppTheme.kTextSub, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // ── GPS button — label adapts to state
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLocating ? null : _useCurrentLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0A1828),
                      ),
                    )
                  : Icon(
                      _isPermanentlyDenied
                          ? Icons.settings_rounded
                          : Icons.my_location_rounded,
                      size: 18,
                    ),
              label: Text(
                _isLocating
                    ? 'Detecting...'
                    : _isPermanentlyDenied
                    ? 'Open settings'
                    : 'Use current location',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: const Color(0xFF0A1828),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── Error + action
          if (_errorMsg != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                      // Only show "Open Settings" link when permanently denied
                      if (_isPermanentlyDenied) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => openAppSettings(),
                          child: const Text(
                            'Tap here or the button above to open Settings.',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: AppTheme.kBorder, thickness: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(color: AppTheme.kTextSub, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Divider(color: AppTheme.kBorder, thickness: 0.5),
                ),
              ],
            ),
          ),

          const Text(
            'Enter city manually',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _confirmManual(),
                  decoration: InputDecoration(
                    hintText: 'e.g. London, Phnom Penh...',
                    hintStyle: TextStyle(
                      color: AppTheme.kTextSub,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.kTextSub,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppTheme.kBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _confirmManual,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0A1828),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
