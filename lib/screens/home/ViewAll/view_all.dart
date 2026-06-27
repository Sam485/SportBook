import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/static/services/data_service.dart';
import 'package:sportbook/widgets/cards/booking_card.dart';
import 'package:sportbook/widgets/cards/club_card.dart';
import '../../../feature/static/models/models.dart';

class ViewAll extends StatefulWidget {
  final String title;
  final List<dynamic> data;

  const ViewAll({super.key, required this.title, required this.data});

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  String _selectedCat = 'all';

  // Changed from SportClub to SportClubModel
  bool get _isClubs =>
      widget.data.isEmpty || widget.data.first is SportClubModel;

  List<dynamic> get _filtered {
    if (_selectedCat == 'all') return widget.data;
    if (_isClubs) {
      return widget.data
          .cast<SportClubModel>()
          .where(
            (c) => c.categories.any(
              (cat) => cat.toString().toLowerCase() == _selectedCat,
            ),
          )
          .toList();
    } else {
      return widget.data
          .cast<SportBooking>()
          // ignore: unrelated_type_equality_checks
          .where((b) => b.sportTypes == _selectedCat)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

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
          widget.title,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _categories(isDark)),
            if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    _isClubs
                        ? 'No clubs for this sport'
                        : 'No bookings for this sport',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else if (_isClubs)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClubCard(
                      club: filtered[i] as SportClubModel,
                    ), // Changed to SportClubModel
                  ),
                  childCount: filtered.length,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BookingCard(booking: filtered[i]),
                  ),
                  childCount: filtered.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categories(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DataService.categories.length,
        itemBuilder: (_, i) {
          final cat = DataService.categories[i];
          final sel = _selectedCat == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? AppTheme.kAccent
                    : (isDark ? AppTheme.kCard : AppTheme.kLightCard),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: sel
                      ? AppTheme.kAccent
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: AppTheme.kAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: sel
                          ? const Color(0xFF0A1828)
                          : (isDark ? Colors.white60 : AppTheme.kLightTextSub),
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
