import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
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

  GetAllBookingDto? _bookingsData;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = '';
  int _currentPage = 1;
  final int _limit = 10;
  int _refreshCounter = 0;

  // Get the list of bookings from the response
  List<BookingModel> get _bookings => _bookingsData?.data ?? [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // In BookingsScreen, ensure data is refreshed when the screen is viewed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible again
    if (!_isLoading && _bookingsData != null) {
      _fetchBookings();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBookings() async {
    await _fetchBookings();
  }

  void _changeStatus(String? status) {
    setState(() {
      _selectedStatus = status ?? '';
      _currentPage = 1;
    });
    _fetchBookings();
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
              actions: [_buildStatusFilterButton(context, isDark)],
            )
          : null,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
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
                          onBookingUpdated: _refreshBookings, // ✅ Pass callback
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
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'failed_to_load_bookings'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'unknown_error'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'retry'.tr(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
