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
      PermissionStatus status = await Permission.location.status;

      if (status.isPermanentlyDenied) {
        setState(() {
          _isPermanentlyDenied = true;
          _errorMsg = 'Location permission is permanently denied.';
          _isLocating = false;
        });
        return;
      }

      status = await Permission.location.request();

      if (status.isDenied) {
        setState(() {
          _isPermanentlyDenied = false;
          _errorMsg = 'Permission denied. Tap the button to try again.';
          _isLocating = false;
        });
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() {
          _isPermanentlyDenied = true;
          _errorMsg =
              'Permission permanently denied. Open settings to allow it.';
          _isLocating = false;
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMsg = 'Location services are off. Please enable them.';
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
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
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select location',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use your current location or type a city name.',
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // ── GPS button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLocating ? null : _useCurrentLocation,
              icon: _isLocating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? const Color(0xFF0A1828) : Colors.white,
                      ),
                    )
                  : Icon(
                      _isPermanentlyDenied
                          ? Icons.settings_rounded
                          : Icons.my_location_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF0A1828) : Colors.white,
                    ),
              label: Text(
                _isLocating
                    ? 'Detecting...'
                    : _isPermanentlyDenied
                    ? 'Open settings'
                    : 'Use current location',
                style: TextStyle(
                  color: isDark ? const Color(0xFF0A1828) : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: isDark
                    ? const Color(0xFF0A1828)
                    : Colors.white,
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
                  child: Divider(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    thickness: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Text(
            'Enter city manually',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 14,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _confirmManual(),
                  decoration: InputDecoration(
                    hintText: 'e.g. London, Bangkok...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
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
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: isDark ? const Color(0xFF0A1828) : Colors.white,
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
