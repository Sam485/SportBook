import 'package:flutter/material.dart';
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
    // Refresh data when screen becomes visible again
    if (_isAuthenticated && !_isLoading && _bookingsData != null && mounted) {
      _fetchBookings();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Check if user is authenticated
  Future<void> _checkAuthentication() async {
    setState(() {
      _isCheckingAuth = true;
    });

    try {
      final hasValidToken = await _tokenService.hasValidTokenAsync();

      if (!hasValidToken) {
        // Try to refresh token
        final refreshToken = await _tokenService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _tokenService.refreshAccessToken();
          if (!refreshed) {
            _isAuthenticated = false;
            setState(() {
              _isCheckingAuth = false;
            });
            return;
          }
        } else {
          _isAuthenticated = false;
          setState(() {
            _isCheckingAuth = false;
          });
          return;
        }
      }

      _isAuthenticated = true;
      setState(() {
        _isCheckingAuth = false;
      });

      // Load bookings if authenticated
      _fetchBookings();
    } catch (e) {
      print('Auth check error: $e');
      _isAuthenticated = false;
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  Future<void> _fetchBookings() async {
    if (!_isAuthenticated) return;

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

      if (mounted) {
        setState(() {
          _bookingsData = data;
          _isLoading = false;
          _refreshCounter++;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBookings() async {
    if (!_isAuthenticated) return;
    await _fetchBookings();
  }

  void _changeStatus(String? status) {
    if (!_isAuthenticated) return;
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
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => Navigator.pop(context),
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
            ? const Center(child: CircularProgressIndicator())
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

  // ✅ Login required state
  Widget _buildLoginRequiredState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
            ),
            const SizedBox(height: 24),
            Text(
              'login_required'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'login_to_view_bookings'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'login'.tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterButton(BuildContext context, bool isDark) {
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
                // Search with debounce
                _fetchBookings();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(bool isDark) {
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
                    setState(() {
                      _currentPage--;
                    });
                    _fetchBookings();
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
                    setState(() {
                      _currentPage++;
                    });
                    _fetchBookings();
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
