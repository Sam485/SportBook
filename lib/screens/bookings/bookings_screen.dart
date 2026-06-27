// bookings_screen.dart - WITH LOGIN REQUIRED STATE STYLED
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/booked_card.dart';

class BookingsScreen extends StatefulWidget {
  final bool isView;
  const BookingsScreen({super.key, required this.isView});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookingService _bookingService = getIt<BookingService>();
  final TokenService _tokenService = getIt<TokenService>();

  GetAllBookingDto? _bookingsData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasError = false;
  String _selectedStatus = '';
  int _currentPage = 1;
  final int _limit = 10;
  int _refreshCounter = 0;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  bool _isDisposed = false;

  // Get the list of bookings from the response
  List<BookingModel> get _bookings => _bookingsData?.data ?? [];

  // ✅ Get user-friendly error message
  String get _userFriendlyErrorMessage {
    if (_errorMessage == null) return 'something_went_wrong'.tr(context);

    final msg = _errorMessage!.toLowerCase();
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'connection_timeout'.tr(context);
    } else if (msg.contains('network') || msg.contains('internet')) {
      return 'network_error'.tr(context);
    } else if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'unauthorized'.tr(context);
    } else if (msg.contains('500') || msg.contains('server')) {
      return 'server_error'.tr(context);
    } else if (msg.contains('404') || msg.contains('not found')) {
      return 'not_found'.tr(context);
    } else {
      return 'something_went_wrong'.tr(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isAuthenticated &&
        !_isLoading &&
        _bookingsData != null &&
        mounted &&
        !_isDisposed) {
      _fetchBookings();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Check if user is authenticated
  Future<void> _checkAuthentication() async {
    if (!mounted || _isDisposed) return;

    setState(() {
      _isCheckingAuth = true;
    });

    try {
      final hasValidToken = await _tokenService.hasValidTokenAsync();

      if (!hasValidToken) {
        final refreshToken = await _tokenService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _tokenService.refreshAccessToken();
          if (!refreshed) {
            _isAuthenticated = false;
            if (mounted && !_isDisposed) {
              setState(() {
                _isCheckingAuth = false;
              });
            }
            return;
          }
        } else {
          _isAuthenticated = false;
          if (mounted && !_isDisposed) {
            setState(() {
              _isCheckingAuth = false;
            });
          }
          return;
        }
      }

      _isAuthenticated = true;
      if (mounted && !_isDisposed) {
        setState(() {
          _isCheckingAuth = false;
        });
      }

      // Load bookings if authenticated
      _fetchBookings();
    } catch (e) {
      _isAuthenticated = false;
      if (mounted && !_isDisposed) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  Future<void> _fetchBookings() async {
    if (!_isAuthenticated || !mounted || _isDisposed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasError = false;
    });

    try {
      final data = await _bookingService.getAllBookings(
        page: _currentPage,
        limit: _limit,
        status: _selectedStatus,
      );

      if (mounted && !_isDisposed) {
        setState(() {
          _bookingsData = data;
          _isLoading = false;
          _refreshCounter++;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = e.toString();
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBookings() async {
    if (!_isAuthenticated || !mounted || _isDisposed) return;
    await _fetchBookings();
  }

  void _changeStatus(String? status) {
    if (!_isAuthenticated || !mounted || _isDisposed) return;
    setState(() {
      _selectedStatus = status ?? '';
      _currentPage = 1;
      _hasError = false;
      _errorMessage = null;
    });
    _fetchBookings();
  }

  // ✅ Navigate to login screen
  void _navigateToLogin() {
    if (!mounted || _isDisposed) return;
    Navigator.pushNamed(context, AppRoutes.login);
  }

  // ✅ Navigate to sign up screen
  void _navigateToSignUp() {
    if (!mounted || _isDisposed) return;
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: widget.isView
          ? AppBar(
              backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  if (mounted && !_isDisposed) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                'my_bookings'.tr(context),
                style: AppTheme.tsTitleAdaptive(context),
              ),
              centerTitle: true,
              actions: _isAuthenticated
                  ? [_buildStatusFilterButton(context, isDark)]
                  : null,
            )
          : null,
      body: SafeArea(
        child: _isCheckingAuth
            ? const Center(child: CircularProgressIndicator())
            : !_isAuthenticated
            ? _buildLoginRequiredState(isDark)
            : _isLoading
            ? _buildSkeletonLoading(isDark)
            : _hasError && _bookings.isEmpty
            ? _buildErrorState(isDark)
            : _bookings.isEmpty
            ? _buildEmptyState(isDark)
            : RefreshIndicator(
                onRefresh: _refreshBookings,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _searchBar(isDark)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => BookedCard(
                          key: ValueKey(
                            'booking_${_bookings[i].id}_$_refreshCounter',
                          ),
                          booking: _bookings[i],
                          onBookingUpdated: _refreshBookings,
                        ),
                        childCount: _bookings.length,
                      ),
                    ),
                    if (_bookingsData != null && _bookingsData!.total > _limit)
                      SliverToBoxAdapter(child: _buildPagination(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
    );
  }

  // ✅ Login Required State - Styled like the image
  Widget _buildLoginRequiredState(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User avatar / icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                border: Border.all(
                  color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
              ),
            ),
            const SizedBox(height: 24),

            // "You are not signed in" text
            Text(
              'you_are_not_signed_in'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // "Sign in to access your bookings" text
            Text(
              'sign_in_to_access_bookings'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'sign_in'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _navigateToSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppTheme.kLightText,
                  side: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'create_account'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Skeleton Loading Widget
  Widget _buildSkeletonLoading(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: skeletonBaseColor,
        highlightColor: skeletonHighlightColor,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports,
                    color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 120,
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            height: 10,
                            width: 60,
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 10,
                            width: 40,
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                          const Spacer(),
                          Container(
                            height: 24,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppTheme.kAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilterButton(BuildContext context, bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.filter_list,
        color: isDark ? Colors.white : Colors.black,
      ),
      onSelected: _changeStatus,
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('All')),
        const PopupMenuItem(value: 'pending', child: Text('Pending')),
        const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
        const PopupMenuItem(value: 'completed', child: Text('Completed')),
        const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
      ],
    );
  }

  Widget _buildErrorState(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
            ),
            const SizedBox(height: 16),
            Text(
              _userFriendlyErrorMessage,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('retry'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'no_bookings_found'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatus.isEmpty
                  ? 'no_bookings_desc'.tr(context)
                  : 'no_bookings_status_desc'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedStatus.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _changeStatus(''),
                child: Text(
                  'clear_filters'.tr(context),
                  style: const TextStyle(color: AppTheme.kAccent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _searchBar(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();
    if (!_isAuthenticated) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration:
                  AppTheme.textFieldDecoration(
                    Icons.search,
                    'search'.tr(context),
                  ).copyWith(
                    labelText: 'search_bookings'.tr(context),
                    labelStyle: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                    ),
                  ),
              onChanged: (value) {
                if (mounted && !_isDisposed) {
                  setState(() {});
                  _fetchBookings();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();
    if (_bookingsData == null) return const SizedBox.shrink();

    final totalPages = (_bookingsData!.total / _limit).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    if (mounted && !_isDisposed) {
                      setState(() {
                        _currentPage--;
                      });
                      _fetchBookings();
                    }
                  }
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: _currentPage > 1
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey,
            ),
          ),
          Text(
            '$_currentPage / $totalPages',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            ),
          ),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () {
                    if (mounted && !_isDisposed) {
                      setState(() {
                        _currentPage++;
                      });
                      _fetchBookings();
                    }
                  }
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _currentPage < totalPages
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
