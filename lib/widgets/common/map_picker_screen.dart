import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../translations/app_translations.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialLabel;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialLabel,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // ── Map state ───────────────────────────────────────────────────────────────
  late LatLng _pinLocation;
  final MapController _mapController = MapController();

  bool _isResolving = false;
  bool _isFetchingGps = false;
  String _resolvedLabel = '';
  bool _isInitialLoad = true;
  bool _isDisposed = false;

  // ── Search state ────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  bool _isGeocoding = false;
  List<_SearchResult> _results = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing location or default
    _initializeLocation();
    
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && !_isDisposed) {
            setState(() => _isSearching = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Initialize Location ──────────────────────────────────────────────────────

  void _initializeLocation() {
    // Use existing coordinates if provided
    if (widget.initialLat != null && widget.initialLng != null) {
      _pinLocation = LatLng(widget.initialLat!, widget.initialLng!);
      _resolvedLabel = widget.initialLabel ?? 'Current Location';
    } else {
      // Default to Phnom Penh
      _pinLocation = const LatLng(11.5564, 104.9282);
      _resolvedLabel = 'Phnom Penh';
    }
  }

  Future<void> _loadCurrentLocation() async {
    if (_isDisposed) return;
    
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      await _goToCurrentLocation(animateMap: false);
    } else if (status.isDenied) {
      final newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        await _goToCurrentLocation(animateMap: false);
      }
    }
    
    if (_isDisposed) return;
    
    // Resolve label for the current pin location
    await _resolveLabel(_pinLocation);
    
    setState(() {
      _isInitialLoad = false;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _mapController.move(_pinLocation, 14);
      }
    });
  }

  // ── Reverse-geocode ──────────────────────────────────────────────────────────

  Future<void> _resolveLabel(LatLng point) async {
    if (_isDisposed) return;
    
    if (mounted) {
      setState(() => _isResolving = true);
    }
    try {
      final marks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (marks.isNotEmpty && mounted && !_isDisposed) {
        final p = marks.first;
        final label = (p.locality?.isNotEmpty == true)
            ? p.locality!
            : (p.subAdministrativeArea?.isNotEmpty == true)
            ? p.subAdministrativeArea!
            : p.administrativeArea ??
                  '${point.latitude.toStringAsFixed(4)}, '
                  '${point.longitude.toStringAsFixed(4)}';
        setState(() => _resolvedLabel = label);
      }
    } catch (_) {
      if (mounted && !_isDisposed) {
        setState(
          () => _resolvedLabel =
              '${point.latitude.toStringAsFixed(4)}, '
              '${point.longitude.toStringAsFixed(4)}',
        );
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isResolving = false);
      }
    }
  }

  // ── Forward-geocode (search) ─────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    if (_isDisposed) return;
    
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      if (mounted && !_isDisposed) {
        setState(() {
          _results = [];
          _isGeocoding = false;
        });
      }
      return;
    }
    
    if (mounted && !_isDisposed) {
      setState(() => _isGeocoding = true);
    }
    
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (_isDisposed) return;
      
      try {
        final locations = await locationFromAddress(query.trim());
        if (!mounted || _isDisposed) return;
        
        final results = <_SearchResult>[];
        for (final loc in locations.take(5)) {
          final pt = LatLng(loc.latitude, loc.longitude);
          String label =
              '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
          try {
            final marks = await placemarkFromCoordinates(
              loc.latitude,
              loc.longitude,
            );
            final p = marks.first;
            final parts = [
              if (p.name?.isNotEmpty == true &&
                  p.name != p.locality &&
                  p.name != p.administrativeArea)
                p.name,
              if (p.locality?.isNotEmpty == true) p.locality,
              if (p.administrativeArea?.isNotEmpty == true)
                p.administrativeArea,
              if (p.country?.isNotEmpty == true) p.country,
            ];
            if (parts.isNotEmpty) label = parts.join(', ');
          } catch (_) {}
          results.add(_SearchResult(label: label, point: pt));
        }
        
        if (mounted && !_isDisposed) {
          setState(() {
            _results = results;
            _isGeocoding = false;
          });
        }
      } catch (_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _results = [];
            _isGeocoding = false;
          });
        }
      }
    });
  }

  void _selectResult(_SearchResult result) {
    if (_isDisposed) return;
    
    _searchCtrl.text = result.label;
    _searchFocus.unfocus();
    setState(() {
      _isSearching = false;
      _results = [];
      _pinLocation = result.point;
      _resolvedLabel = result.label;
    });
    _mapController.move(result.point, 14);
  }

  void _clearSearch() {
    if (_isDisposed) return;
    
    _searchCtrl.clear();
    setState(() {
      _results = [];
      _isGeocoding = false;
    });
  }

  // ── GPS ──────────────────────────────────────────────────────────────────────

  Future<void> _goToCurrentLocation({bool animateMap = true}) async {
    if (_isDisposed) return;
    
    if (mounted) {
      setState(() => _isFetchingGps = true);
    }
    
    try {
      var status = await Permission.location.status;
      if (status.isDenied) status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are off'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      final newPin = LatLng(pos.latitude, pos.longitude);
      
      if (_isDisposed) return;
      
      setState(() => _pinLocation = newPin);
      
      await _resolveLabel(newPin);
      
      if (mounted && !_isDisposed) {
        _searchCtrl.text = _resolvedLabel;
        if (animateMap) {
          _mapController.move(newPin, 14);
        }
      }
    } catch (_) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get location'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isFetchingGps = false);
      }
    }
  }

  // ── Confirm ──────────────────────────────────────────────────────────────────

  void _confirm() {
    if (!_isDisposed && mounted) {
      Navigator.pop(context, _resolvedLabel);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: GestureDetector(
        onTap: () {
          _searchFocus.unfocus();
          if (mounted && !_isDisposed) {
            setState(() => _isSearching = false);
          }
        },
        child: Stack(
          children: [
            // ── Map ──────────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pinLocation,
                initialZoom: 14,
                onPositionChanged: (MapCamera camera, bool hasGesture) {
                  if (hasGesture && mounted && !_isDisposed) {
                    setState(() => _pinLocation = camera.center);
                  }
                },
                onMapEvent: (event) {
                  if ((event is MapEventMoveEnd ||
                      event is MapEventScrollWheelZoom) && !_isDisposed) {
                    _resolveLabel(_pinLocation);
                    if (!_isSearching) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_isDisposed) {
                          _searchCtrl.text = _resolvedLabel;
                        }
                      });
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sportbook',
                ),
              ],
            ),

            // ── Centre pin ───────────────────────────────────────────────────
            const Center(child: _CentrePin()),

            // ── Top bar (search + GPS) ────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Back
                          _CircleButton(
                            isDark: isDark,
                            onTap: () {
                              if (!_isDisposed && mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // ── Search field ──────────────────────────────────
                          Expanded(
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.kCard : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  _isSearching && _results.isNotEmpty ? 14 : 30,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Icon(
                                    _isGeocoding
                                        ? Icons.hourglass_top_rounded
                                        : Icons.search_rounded,
                                    color: _isGeocoding
                                        ? AppTheme.kAccent
                                        : (isDark
                                              ? AppTheme.kTextSub
                                              : AppTheme.kLightTextSub),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      focusNode: _searchFocus,
                                      onTap: () {
                                        if (mounted && !_isDisposed) {
                                          setState(() => _isSearching = true);
                                        }
                                      },
                                      onChanged: _onSearchChanged,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (v) => _onSearchChanged(v),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.kLightText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search location...',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? AppTheme.kTextSub
                                              : AppTheme.kLightTextSub,
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  if (_searchCtrl.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: _clearSearch,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: isDark
                                              ? AppTheme.kTextSub
                                              : AppTheme.kLightTextSub,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // GPS
                          _CircleButton(
                            isDark: isDark,
                            isLoading: _isFetchingGps,
                            onTap: _isFetchingGps ? null : () => _goToCurrentLocation(animateMap: true),
                            child: Icon(
                              Icons.my_location_rounded,
                              color: AppTheme.kAccent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // ── Search results dropdown ───────────────────────────
                      if (_isSearching && _results.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                            left: 54,
                            right: 54,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.kCard : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < _results.length; i++) ...[
                                  if (i > 0)
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: isDark
                                          ? AppTheme.kBorder
                                          : AppTheme.kLightBorder,
                                      indent: 44,
                                    ),
                                  _ResultTile(
                                    result: _results[i],
                                    isDark: isDark,
                                    onTap: () => _selectResult(_results[i]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                      // Loading indicator below search bar
                      if (_isSearching && _isGeocoding && _results.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                            left: 54,
                            right: 54,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.kCard : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.kAccent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Searching...',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.kTextSub
                                      : AppTheme.kLightTextSub,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom confirm bar ────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.kCard.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isResolving)
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppTheme.kAccent,
                                ),
                              )
                            else
                              Icon(
                                Icons.location_on_rounded,
                                color: AppTheme.kAccent,
                                size: 13,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _isResolving
                                  ? 'Loading...'
                                  : _resolvedLabel,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.kTextSub
                                    : AppTheme.kLightTextSub,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isResolving ? null : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kAccent,
                            foregroundColor: isDark
                                ? const Color(0xFF0A1828)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text('Confirm Location'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search result model ───────────────────────────────────────────────────────

class _SearchResult {
  const _SearchResult({required this.label, required this.point});
  final String label;
  final LatLng point;
}

// ── Result tile ───────────────────────────────────────────────────────────────

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.isDark,
    required this.onTap,
  });

  final _SearchResult result;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.kAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: AppTheme.kAccent,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.north_west_rounded,
              size: 14,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Centre pin ────────────────────────────────────────────────────────────────

class _CentrePin extends StatelessWidget {
  const _CentrePin();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.kAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.kAccent.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_pin,
              color: Color(0xFF0A1828),
              size: 24,
            ),
          ),
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.kAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 8,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle icon button ────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.isDark,
    required this.child,
    this.onTap,
    this.isLoading = false,
  });

  final bool isDark;
  final Widget child;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCard : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.kAccent,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}