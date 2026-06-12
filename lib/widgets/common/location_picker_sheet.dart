import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../translations/app_translations.dart';
import 'map_picker_screen.dart';

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

  // ── GPS / Current Location ──────────────────────────────────────────────────

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
          _errorMsg = 'location_permission_denied'.tr(context);
          _isLocating = false;
        });
        return;
      }

      status = await Permission.location.request();

      if (status.isDenied) {
        setState(() {
          _isPermanentlyDenied = false;
          _errorMsg = 'permission_denied_try_again'.tr(context);
          _isLocating = false;
        });
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() {
          _isPermanentlyDenied = true;
          _errorMsg = 'permission_permanently_denied'.tr(context);
          _isLocating = false;
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMsg = 'location_services_off'.tr(context);
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
        _errorMsg = 'could_not_get_location'.tr(context);
        _isLocating = false;
      });
    }
  }

  // ── Open full-screen map picker ─────────────────────────────────────────────

  Future<void> _openMapPicker() async {
    // Close the sheet first, then open map as a full-screen route so the
    // result can bubble back to the HomeScreen via Navigator.
    Navigator.pop(context, _kOpenMap); // sentinel value
  }

  static const String _kOpenMap = '__open_map__';

  // ── Manual text entry ───────────────────────────────────────────────────────

  void _confirmManual() {
    final text = _searchCtrl.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
          // ── Handle ──
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

          // ── Title ──
          Text(
            'select_location'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'location_description'.tr(context),
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // ── Two primary action buttons ──
          Row(
            children: [
              // Current Location
              Expanded(
                child: _ActionTile(
                  icon: _isLocating
                      ? null
                      : (_isPermanentlyDenied
                            ? Icons.settings_rounded
                            : Icons.my_location_rounded),
                  isLoading: _isLocating,
                  label: _isLocating
                      ? 'detecting_location'.tr(context)
                      : _isPermanentlyDenied
                      ? 'open_settings'.tr(context)
                      : 'use_current_location'.tr(context),
                  isDark: isDark,
                  onTap: _isLocating ? null : _useCurrentLocation,
                ),
              ),
              const SizedBox(width: 12),
              // Pin on Map
              Expanded(
                child: _ActionTile(
                  icon: Icons.map_rounded,
                  label: 'pin_on_map'.tr(context),
                  isDark: isDark,
                  onTap: _openMapPicker,
                  isSecondary: true,
                ),
              ),
            ],
          ),

          // ── Error message ──
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
                          child: Text(
                            'tap_to_open_settings'.tr(context),
                            style: const TextStyle(
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

          // ── Divider ──
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
                    'or'.tr(context),
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

          // ── Manual entry ──
          Text(
            'enter_city_manually'.tr(context),
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
                    hintText: 'city_hint'.tr(context),
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

// ── Helper tile widget ──────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.isDark,
    this.icon,
    this.onTap,
    this.isLoading = false,
    this.isSecondary = false,
  });

  final IconData? icon;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final bg = isSecondary
        ? (isDark ? AppTheme.kBg : AppTheme.kLightBg)
        : AppTheme.kAccent;
    final fg = isSecondary
        ? (isDark ? Colors.white : AppTheme.kLightText)
        : (isDark ? const Color(0xFF0A1828) : Colors.white);
    final borderColor = isSecondary
        ? (isDark ? AppTheme.kBorder : AppTheme.kLightBorder)
        : AppTheme.kAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.kAccent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else
              Icon(icon, color: fg, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
