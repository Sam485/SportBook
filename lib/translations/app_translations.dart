import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/providers/language_provider.dart';

/// Centralized translation management for the SportMate app.
/// Supports English ('en') and Khmer ('km') languages.
class AppTranslations {
  // ============================================================================
  // Translation Data
  // ============================================================================

  static const Map<String, Map<String, String>> _translations = {
    // ------------------------------------------------------------------------
    // English Translations
    // ------------------------------------------------------------------------
    'en': {
      // ---------------------- Common UI Elements ----------------------------
      'app_name': 'SportMate',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'no_data': 'No data found',
      'km_away': 'km away',
      'book': 'Book',
      'open': 'Open',
      'closed': 'Closed',
      'view_all': 'View All',
      'no_images': 'No Images',

      // ---------------------- Sports Names ----------------------------
      'sport_football': 'Football',
      'sport_basketball': 'Basketball',
      'sport_tennis': 'Tennis',
      'sport_badminton': 'Badminton',
      'sport_gym': 'Gym',

      // ---------------------- Navigation ----------------------------
      'home': 'Home',
      'explore': 'Explore',
      'bookings': 'Bookings',
      'settings': 'Settings',
      'profile': 'Profile',
      'user': 'User',
      'favorites': 'Favorites',
      'view_favorite_clubs': 'View your favorite clubs',

      // ---------------------- Location Picker ----------------------------
      'select_location': 'Select location',
      'location_description': 'Use your current location or type a city name.',
      'use_current_location': 'Use current location',
      'detecting_location': 'Detecting...',
      'open_settings': 'Open settings',
      'location_permission_denied':
          'Location permission is permanently denied.',
      'permission_denied_try_again':
          'Permission denied. Tap the button to try again.',
      'permission_permanently_denied':
          'Permission permanently denied. Open settings to allow it.',
      'location_services_off': 'Location services are off. Please enable them.',
      'could_not_get_location': 'Could not get location. Try again.',
      'tap_to_open_settings': 'Tap here or the button above to open Settings.',
      'or': 'or',
      'enter_city_manually': 'Enter city manually',
      'city_hint': 'e.g. London, Phnom Penh...',

      // ---------------------- Notification Categories ----------------------------
      'all': 'All',
      'alerts': 'Alerts',
      'messages': 'Messages',
      'promotions': 'Promotions',

      // ---------------------- Home Screen ----------------------------
      'clubs_nearby': 'Clubs Nearby',
      'upcoming_bookings': 'Upcoming Bookings',
      'no_bookings': 'No bookings for this sport',
      'hello_message': 'Hello, {name} 👋',
      'no_clubs_for_sport': 'No clubs for this sport',
      'favorites_empty': 'No favorite clubs yet',
      'favorites_hint': 'Start favoriting clubs you love!',
      'explore_clubs': 'Explore Clubs',

      // ---------------------- Explore Screen ----------------------------
      'nearby': 'Nearby',
      'no_nearby_clubs': 'No nearby club found!',
      'no_results_for': 'No results found for "{query}"',
      'search_hint': 'Search clubs, sports...',

      // ---------------------- Booking ----------------------------
      'search': 'Search',
      'book_now': 'Book Now',
      'select_sport': 'Select Sport',
      'select_court': 'Select Booking',
      'select_date': 'Select Date',
      'select_time': 'Select Time',
      'payment': 'Payment',
      'confirm_booking': 'Confirm Booking',
      'booking_successful': 'Booking Successful!',
      'booking_id': 'Booking ID',
      'total_amount': 'Total Amount',
      'cancel_booking': 'Cancel Booking',
      'keep': 'Keep',
      'entry_pass': 'Entry Pass',
      'qr_instruction': 'Show this QR code at the venue entrance',
      'close': 'Close',
      'booked_on': 'Booked on',
      'cancel_booking_confirmation':
          'Are you sure you want to cancel "{title}"?',
      'reschedule': 'Reschedule',
      'reschedule_coming_soon': 'Reschedule feature coming soon',

      // ---------------------- Booking Flow ----------------------------
      'court': 'Court',
      'date_time': 'Date-Time',
      'category': 'Category',
      'date': 'Date',
      'next': 'Next',
      'court_label': 'Court {number}',
      'today': 'Today',

      // ---------------------- Club Detailed Screen ----------------------------
      'facilities': 'Facilities',
      'sports_available': 'Sports Available',
      'pricing': 'Pricing',
      'location': 'Location',
      'about': 'About',
      'you_might_also_like': 'You Might Also Like',
      'courts': 'Courts',
      'parking': 'Parking',
      'showers': 'Showers',
      'cafe': 'Café',
      'free_wifi': 'Free Wi-Fi',
      'air_con': 'Air-Con',
      'equipment': 'Equipment',
      'restrooms': 'Restrooms',
      'first_aid': 'First Aid',
      'peak_hours': 'Peak Hours (6–9 AM, 5–9 PM)',
      'off_peak_hours': 'Off-Peak Hours',
      'weekend_surcharge': 'Weekend Surcharge',
      'view_on_map': 'View on Map',
      'about_description':
          'is a premium sports facility offering world-class courts and amenities for athletes of all levels. Whether you\'re a casual player or a competitive athlete, our professional-grade facilities and expert staff ensure an exceptional experience every visit.\n\nWe pride ourselves on maintaining top-tier court surfaces, state-of-the-art equipment, and a welcoming community atmosphere.',
      'chat': 'Chat',
      'saved': 'Saved',
      'open_now': 'Open Now',
      'book_court': 'Book Court',

      // ---------------------- Settings Screen ----------------------------
      'settings_title': 'Settings',
      'account': 'Account',
      'preferences': 'Preferences',
      'language': 'Language',
      'appearance': 'Appearance',
      'notifications': 'Notifications',
      'sign_out': 'Sign Out',
      'sign_out_confirmation': 'Are you sure you want to sign out?',
      'sign_out_cancel': 'Cancel',
      'sign_out_confirm': 'Sign Out',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full Name',
      'email_address': 'Email Address',
      'save_changes': 'Save Changes',
      'fill_all_fields': 'Please fill all fields',
      'enter_valid_email': 'Please enter a valid email',
      'history_bookings': 'History Bookings',
      'no_booking_history': 'No booking history',
      'past_bookings_appear_here': 'Your past bookings will appear here',
      'completed': 'Completed',
      'security': 'Security',
      'view_past_sessions': 'View past sessions',
      'last_changed': 'Last changed 3 months ago',
      'total_bookings': 'Bookings',
      'upcoming': 'Upcoming',
      'booking_reminders': 'Booking reminders & alerts',
      'select_language': 'Select Language',
      'english': 'English (US)',
      'khmer': 'Khmer',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_default': 'System Default',
      'dark': 'Dark',
      'light': 'Light',
      'system': 'System',

      // ---------------------- Step Category ----------------------------
      'choose_sport_at': 'Choose a sport to book at {name}',
      'football_subtitle': 'Book a full-size pitch or mini court',
      'badminton_subtitle': 'Indoor court with synthetic surface',
      'tennis_subtitle': 'Hard court or clay surface',
      'basketball_subtitle': '3v3 or 5v5 full court',
      'gym_subtitle': 'Book a personal trainer session',
      'book_your_session': 'Book your session',

      // ---------------------- Step Court ----------------------------
      'select_trainer': 'Select Trainer',
      'select_court_desc':
          'Tap a court to select · Tap the expand icon to preview',
      'choose_trainer_desc': 'Choose a trainer for your session',
      'pinch_to_zoom': 'Pinch to zoom',

      // ---------------------- Step Date & Time ----------------------------
      'choose_date_desc': 'Choose a date for your booking',
      'week_of': 'Week of {date}',
      'current_week': 'Current Week',
      'already_booked': 'Already booked on this court',
      'from_label': 'FROM',
      'to_label': 'TO',
      'pick_start_time_first': 'Pick a start time first',
      'no_available_end_times': 'No available end times',
      'hours': 'hour(s)',

      // ---------------------- Days ----------------------------
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',

      // ---------------------- Months ----------------------------
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dec',

      // ---------------------- Step Payment ----------------------------
      'payment_method': 'Payment Method',
      'choose_payment_desc': 'Choose how you\'d like to pay',
      'select_payment_section': 'SELECT PAYMENT',
      'select_payment_method': 'Please select a payment method',
      'contact_info_section': 'CONTACT INFORMATION',
      'full_name_label': 'Full Name',
      'full_name_hint': 'Enter your full name',
      'full_name_required': 'Please enter your full name',
      'name_min_length': 'Name must be at least 2 characters',
      'phone_label': 'Phone Number',
      'phone_hint': 'Enter your phone number',
      'phone_required': 'Please enter your phone number',
      'phone_invalid': 'Please enter a valid phone number',
      'sport': 'Sport',
      'time': 'Time',
      'khqr_title': 'KHQR / Bank Transfer',
      'khqr_subtitle': 'Scan QR code with any Cambodian banking app',
      'instant': 'Instant',
      'cash_title': 'Cash Payment',
      'cash_subtitle': 'Pay at the venue counter',
      'supported_banks': 'Supported Banks & Wallets',
      'khqr_step1': 'Open your banking app and tap "Scan QR"',
      'khqr_step2': 'Scan the KHQR code above',
      'khqr_step3': 'Confirm the amount and complete the transfer',
      'khqr_step4': 'Tap "Confirm & View QR Code" to finalize your booking',
      'amount_due': 'Amount Due at Venue',
      'usd': 'USD',
      'cash_note':
          'Please arrive 10 minutes early to complete payment at the front desk before your session.',
      'cash_step1': 'Tap "Confirm Booking" to reserve your court',
      'cash_step2': 'Arrive at the venue before your session',
      'cash_step3': 'Show your booking confirmation at the counter',
      'cash_step4': 'Pay the amount in cash and enjoy your game!',

      // ---------------------- Payment Success Page ----------------------------
      'payment_success_title': 'Payment Successful!',
      'payment_success_desc':
          'Your court has been reserved.\nSee you on the court!',
      'view_my_booking': 'View My Booking',
      'return_to_home': 'Return to Home',
      'booking': 'Booking',
      'total_paid': 'Total Paid',

      // ---------------------- Password & Security ----------------------------
      'password_security': 'Password & Security',
      'security_tips': 'Security Tips',
      'strong_password_tip':
          'Use a strong password with letters, numbers, and symbols',
      'change_password_section': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'change_password': 'Change Password',
      'two_factor_auth': 'Two-Factor Authentication',
      'two_factor_desc': 'Add an extra layer of security',
      'two_factor_coming_soon': '2FA coming soon',
      'enter_current_password': 'Please enter current password',
      'enter_new_password': 'Please enter new password',
      'password_min_length': 'Password must be at least 6 characters',
      'passwords_do_not_match': 'Passwords do not match',
      'password_changed_success': 'Password changed successfully!',

      // ---------------------- Booked Detailed Screen ----------------------------
      'payment_summary': 'Payment Summary',
      'field_booking': 'Field Booking',
      'service_fee': 'Service Fee',
      'total': 'Total',
      'booking_details': 'Booking Details',
      'status': 'Status',
      'booked_on_date': 'Booked on',
      'cancellation_policy': 'Cancellation Policy',
      'free_cancellation': 'Free cancellation',
      'free_cancellation_desc':
          'Cancel up to 24 hrs before your slots for a full refund.',
      'late_cancellation': 'Late cancellation',
      'late_cancellation_desc':
          'Within 24 hrs - 50% of booking cost is charged.',
      'no_show': 'No-show',
      'no_show_desc':
          'Full charge applies. Contact support if you have an emergency.',
      'scan_at_gate': 'Scan at the gate',
      'qr_instruction_detailed':
          'Show this QR code to the staff on arrival. Valid only for your booked slot on Jun 7, 2026',
      'expires_in_days': 'Expires in 3 days',
      'cancel_booking_warning':
          'Are you sure you want to cancel this booking? Cancellation fees may apply.',
      'no_keep_it': 'No, Keep It',
      'yes_cancel': 'Yes, Cancel',
      'share_coming_soon': 'Share feature coming soon',
      'hosted_by': 'Hosted by {name}',
      'response_rate': 'Response rate: 98%',

      // ---------------------- Authentication ----------------------------
      'login': 'Login',
      'sign_up': 'Sign Up',
      'phone_or_username': 'Phone or Username',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'remember_me': 'Remember Me',
      'dont_have_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      'verify_phone': 'Verify Your Phone',
      'enter_otp': 'Enter the 6-digit code sent to your phone',
      'resend_code': 'Didn\'t receive the code?',
      'resend': 'Resend',
      'verify': 'Verify',
      'welcome_back': 'Welcome back! Please Sign in to continue',
      'valid_phone_required': 'Please enter a valid phone number',
      'password_hint': 'Enter your password',
      'password_required': 'Password is required',
      'create_account_desc': 'Create your account to get started',
      'phone': 'Phone',
      'confirm_password_required': 'Please confirm your password',
      'confirm_password_hint': 'Confirm your password',
      'password_mismatch': "Password doesn't match",
      'reset_password_desc': 'Reset your password',
      'reset_password': 'Reset Password',
      'remembered_password': 'Remembered your password?',
      'resend_in': 'Resend in {seconds}s',
      'back_to': 'Back to ',
      'email_phone_username': 'Email, Phone or Username',
      'email_phone_username_hint': 'Enter your email, phone or username',
      'identifier_required': 'Email, phone or username is required',
      'invalid_email_format':
          'Please enter a valid email address (e.g., user@example.com)',
      'invalid_phone_format':
          'Please enter a valid Cambodian phone number (e.g., 0123456789, 85512345678, +85512345678)',
      'invalid_phone_length':
          'Phone number must be 9-10 digits after country code',
      'username_too_short': 'Username must be at least 3 characters',
      'username_too_long': 'Username must be less than 30 characters',
      'invalid_identifier':
          'Please enter a valid email, phone number, or username (letters, numbers, dots, underscores)',
      'login_success': 'Login successful!',
      'login_failed': 'Login failed. Please check your credentials',

      // ---------------------- Create Profile Screen ----------------------------
      'choose_photo': 'Choose Photo',
      'choose_from_library': 'Choose from Library',
      'take_a_photo': 'Take a Photo',
      'remove_photo': 'Remove Photo',
      'create_profile_title': 'Create Your Profile',
      'create_profile_desc':
          'Set up your profile so other players\ncan find and connect with you.',
      'username': 'Username',
      'username_required': 'Username is required',
      'username_min_length': 'Username must be at least 3 characters',
      'username_no_spaces': 'Username cannot contain spaces',
      'username_hint': 'e.g. john_doe',
      'email': 'Email',
      'optional': 'Optional',
      'email_hint': 'your@email.com',
      'valid_email_required': 'Please enter a valid email address',
      'create_profile': 'Create Profile',
      'skip_for_now': 'Skip for now',

      // ---------------------- Messages ----------------------------
      'booking_cancelled': 'Booking cancelled successfully',
      'profile_updated': 'Profile updated successfully',
      'password_changed': 'Password changed successfully',
      'all_notifications_read': 'All notifications marked as read',

      // ---------------------- Time ----------------------------
      'tomorrow': 'Tomorrow',
      'yesterday': 'Yesterday',

      // ---------------------- Status ----------------------------
      'confirmed': 'Confirmed',
      'pending': 'Pending',
      'cancelled': 'Cancelled',

      // ---------------------- Landing Screen ----------------------------
      'banner_title_1': 'Book Your\nGame Today!',
      'banner_title_2': 'Find Courts\nInstantly',
      'banner_title_3': 'Meet & Play\nWith Others',
      'banner_title_4': 'Track Every\nPerformance',
      'banner_desc_1':
          'Find courts, book slots, and connect with players near you — all in one place.',
      'banner_desc_2':
          'Discover available basketball courts, check real-time slot availability and reserve in seconds.',
      'banner_desc_3':
          'Join local games, challenge nearby players, and grow your sports community.',
      'banner_desc_4':
          'Log your sessions, monitor progress, and push your personal best every time you play.',
    },

    // ------------------------------------------------------------------------
    // Khmer Translations
    // ------------------------------------------------------------------------
    'km': {
      // ---------------------- Common UI Elements ----------------------------
      'app_name': 'ស្ព័រមិត្ត',
      'ok': 'យល់ព្រម',
      'cancel': 'បោះបង់',
      'save': 'រក្សាទុក',
      'delete': 'លុប',
      'loading': 'កំពុងផ្ទុក...',
      'error': 'កំហុស',
      'retry': 'ព្យាយាមម្តងទៀត',
      'no_data': 'រកមិនឃើញទិន្នន័យ',
      'km_away': 'គីឡូម៉ែត្រ',
      'book': 'កក់',
      'open': 'បើក',
      'closed': 'បិទ',
      'view_all': 'មើលទាំងអស់',
      'no_images': 'គ្មានរូបភាព',

      // ---------------------- Sports Names ----------------------------
      'sport_football': 'បាល់ទាត់',
      'sport_basketball': 'បាល់បោះ',
      'sport_tennis': 'តេនីស',
      'sport_badminton': 'បាត់មីនតុន',
      'sport_gym': 'កន្លែងហាត់ប្រាណ',

      // ---------------------- Navigation ----------------------------
      'home': 'ទំព័រដើម',
      'explore': 'ស្វែងរក',
      'bookings': 'ការកក់',
      'settings': 'ការកំណត់',
      'profile': 'ប្រវត្តិរូប',
      'user': 'អ្នកប្រើប្រាស់',
      'favorites': 'ការពេញចិត្ត',
      'view_favorite_clubs': 'មើលក្លឹបដែលអ្នកចូលចិត្ត',

      // ---------------------- Location Picker ----------------------------
      'select_location': 'ជ្រើសរើសទីតាំង',
      'location_description':
          'ប្រើទីតាំងបច្ចុប្បន្នរបស់អ្នក ឬបញ្ចូលឈ្មោះទីក្រុង',
      'use_current_location': 'ប្រើទីតាំងបច្ចុប្បន្ន',
      'detecting_location': 'កំពុងស្វែងរក...',
      'open_settings': 'បើកការកំណត់',
      'location_permission_denied':
          'ការអនុញ្ញាតទីតាំងត្រូវបានបដិសេធជាអចិន្ត្រៃយ៍',
      'permission_denied_try_again':
          'ការអនុញ្ញាតត្រូវបានបដិសេធ។ ចុចប៊ូតុងដើម្បីព្យាយាមម្តងទៀត',
      'permission_permanently_denied':
          'ការអនុញ្ញាតត្រូវបានបដិសេធជាអចិន្ត្រៃយ៍។ បើកការកំណត់ដើម្បីអនុញ្ញាត',
      'location_services_off': 'សេវាកម្មទីតាំងត្រូវបានបិទ។ សូមបើកពួកវា',
      'could_not_get_location': 'មិនអាចទទួលបានទីតាំង។ សូមព្យាយាមម្តងទៀត',
      'tap_to_open_settings': 'ចុចទីនេះ ឬប៊ូតុងខាងលើដើម្បីបើកការកំណត់',
      'or': 'ឬ',
      'enter_city_manually': 'បញ្ចូលទីក្រុងដោយខ្លួនឯង',
      'city_hint': 'ឧទាហរណ៍ ភ្នំពេញ, សៀមរាប...',

      // ---------------------- Notification Categories ----------------------------
      'all': 'ទាំងអស់',
      'alerts': 'ការជូនដំណឹង',
      'messages': 'សារ',
      'promotions': 'ការផ្សព្វផ្សាយ',

      // ---------------------- Home Screen ----------------------------
      'clubs_nearby': 'ក្លឹបក្បែរអ្នក',
      'upcoming_bookings': 'ការកក់នាពេលខាងមុខ',
      'no_bookings': 'គ្មានការកក់សម្រាប់កីឡានេះ',
      'hello_message': 'សួស្តី, {name} 👋',
      'no_clubs_for_sport': 'គ្មានក្លឹបសម្រាប់កីឡានេះ',
      'favorites_empty': 'មិនទាន់មានក្លឹបដែលអ្នកចូលចិត្តនៅឡើយទេ',
      'favorites_hint': 'ចាប់ផ្តើមចូលចិត្តក្លឹបដែលអ្នកស្រលាញ់!',
      'explore_clubs': 'ស្វែងរកក្លឹប',

      // ---------------------- Explore Screen ----------------------------
      'nearby': 'ក្បែរអ្នក',
      'no_nearby_clubs': 'រកមិនឃើញក្លឹបនៅក្បែរអ្នក!',
      'no_results_for': 'រកមិនឃើញលទ្ធផលសម្រាប់ "{query}"',
      'search_hint': 'ស្វែងរកក្លឹប កីឡា...',

      // ---------------------- Booking ----------------------------
      'search': 'ស្វែងរក',
      'book_now': 'កក់ឥឡូវ',
      'select_sport': 'ជ្រើសរើសកីឡា',
      'select_court': 'ជ្រើសរើសទីលាន',
      'select_date': 'ជ្រើសរើសកាលបរិច្ឆេទ',
      'select_time': 'ជ្រើសរើសម៉ោង',
      'payment': 'ការទូទាត់',
      'confirm_booking': 'បញ្ជាក់ការកក់',
      'booking_successful': 'ការកក់បានជោគជ័យ!',
      'booking_id': 'លេខសម្គាល់ការកក់',
      'total_amount': 'ចំនួនទឹកប្រាក់សរុប',
      'cancel_booking': 'បោះបង់ការកក់',
      'keep': 'រក្សាទុក',
      'entry_pass': 'សំបុត្រចូល',
      'qr_instruction': 'បង្ហាញកូដ QR នេះនៅច្រកចូលកន្លែង',
      'close': 'បិទ',
      'booked_on': 'បានកក់នៅថ្ងៃ',
      'cancel_booking_confirmation':
          'តើអ្នកពិតជាចង់បោះបង់ការកក់ "{title}" មែនទេ?',
      'reschedule': 'កំណត់ពេលវេលាឡើងវិញ',
      'reschedule_coming_soon': 'លក្ខណៈពិសេសកំណត់ពេលវេលាឡើងវិញនឹងមកដល់ឆាប់ៗ',

      // ---------------------- Booking Flow ----------------------------
      'court': 'ទីលាន',
      'date_time': 'កាលបរិច្ឆេទ-ម៉ោង',
      'category': 'ប្រភេទ',
      'date': 'កាលបរិច្ឆេទ',
      'next': 'បន្ទាប់',
      'court_label': 'ទីលានលេខ {number}',
      'today': 'ថ្ងៃនេះ',

      // ---------------------- Club Detailed Screen ----------------------------
      'facilities': 'បរិក្ខារ',
      'sports_available': 'កីឡាដែលអាចលេងបាន',
      'pricing': 'តម្លៃ',
      'location': 'ទីតាំង',
      'about': 'អំពីយើង',
      'you_might_also_like': 'អ្នកក៏អាចចូលចិត្ត',
      'courts': 'ទីលាន',
      'parking': 'ចំណតរថយន្ត',
      'showers': 'បន្ទប់ទឹក',
      'cafe': 'ហាងកាហ្វេ',
      'free_wifi': 'វ៉ាយហ្វាយឥតគិតថ្លៃ',
      'air_con': 'ម៉ាស៊ីនត្រជាក់',
      'equipment': 'ឧបករណ៍',
      'restrooms': 'បន្ទប់ទឹក',
      'first_aid': 'ឧបករណ៍សង្គ្រោះបឋម',
      'peak_hours': 'ម៉ោងកំពូល (៦–៩ ព្រឹក, ៥–៩ ល្ងាច)',
      'off_peak_hours': 'ម៉ោងធម្មតា',
      'weekend_surcharge': 'ការគិតថ្លៃបន្ថែមចុងសប្តាហ៍',
      'view_on_map': 'មើលនៅលើផែនទី',
      'about_description':
          'គឺជាកន្លែងកីឡាដ៏ល្អដែលផ្តល់ជូននូវទីលាន និងបរិក្ខារលំដាប់ពិភពលោកសម្រាប់អត្តពលិកគ្រប់កម្រិត។ មិនថាអ្នកជាអ្នកលេងកម្សាន្ត ឬអត្តពលិកប្រកួតប្រជែងទេ បរិក្ខារលំដាប់អាជីព និងបុគ្គលិកជំនាញរបស់យើងធានាបាននូវបទពិសោធន៍ពិសេសរៀងរាល់ដង។\n\nយើងមានមោទនភាពក្នុងការថែរក្សាគុណភាពផ្ទៃទីលាន ឧបករណ៍ទំនើប និងបរិយាកាសសហគមន៍ដ៏កក់ក្ដៅ។',
      'chat': 'ជជែក',
      'saved': 'បានរក្សាទុក',
      'open_now': 'កំពុងបើក',
      'book_court': 'កក់ទីលាន',

      // ---------------------- Settings Screen ----------------------------
      'settings_title': 'ការកំណត់',
      'account': 'គណនី',
      'preferences': 'ចំណូលចិត្ត',
      'language': 'ភាសា',
      'appearance': 'រូបរាង',
      'notifications': 'ការជូនដំណឹង',
      'sign_out': 'ចាកចេញ',
      'sign_out_confirmation': 'តើអ្នកពិតជាចង់ចាកចេញមែនទេ?',
      'sign_out_cancel': 'បោះបង់',
      'sign_out_confirm': 'ចាកចេញ',
      'edit_profile': 'កែប្រវត្តិរូប',
      'full_name': 'ឈ្មោះពេញ',
      'email_address': 'អាសយដ្ឋានអ៊ីមែល',
      'save_changes': 'រក្សាទុកការផ្លាស់ប្តូរ',
      'fill_all_fields': 'សូមបំពេញគ្រប់វាល',
      'enter_valid_email': 'សូមបញ្ចូលអ៊ីមែលដែលមានសុពលភាព',
      'history_bookings': 'ប្រវត្តិការកក់',
      'no_booking_history': 'គ្មានប្រវត្តិការកក់',
      'past_bookings_appear_here': 'ការកក់មុនរបស់អ្នកនឹងបង្ហាញនៅទីនេះ',
      'completed': 'បានបញ្ចប់',
      'security': 'សុវត្ថិភាព',
      'view_past_sessions': 'មើលវគ្គមុនៗ',
      'last_changed': 'បានផ្លាស់ប្តូរចុងក្រោយកាលពី ៣ ខែមុន',
      'total_bookings': 'ការកក់',
      'upcoming': 'នាពេលខាងមុខ',
      'booking_reminders': 'ការរំលឹក និងដំណឹងជូនដំណឹង',
      'select_language': 'ជ្រើសរើសភាសា',
      'english': 'អង់គ្លេស',
      'khmer': 'ខ្មែរ',
      'dark_mode': 'របៀបងងឹត',
      'light_mode': 'របៀបភ្លឺ',
      'system_default': 'តាមប្រព័ន្ធ',
      'dark': 'ងងឹត',
      'light': 'ភ្លឺ',
      'system': 'ប្រព័ន្ធ',

      // ---------------------- Step Category ----------------------------
      'choose_sport_at': 'ជ្រើសរើសកីឡាដើម្បីកក់នៅ {name}',
      'football_subtitle': 'កក់ទីលានធំ ឬទីលានតូច',
      'badminton_subtitle': 'ទីលានក្នុងផ្ទះជាមួយផ្ទៃសំយោគ',
      'tennis_subtitle': 'ទីលានរឹង ឬដីឥដ្ឋ',
      'basketball_subtitle': 'ទីលាន ៣នាក់ទល់នឹង ៣នាក់ ឬ ៥នាក់ទល់នឹង ៥នាក់',
      'gym_subtitle': 'កក់វគ្គជាមួយគ្រូបង្វឹកផ្ទាល់ខ្លួន',
      'book_your_session': 'កក់វគ្គរបស់អ្នក',

      // ---------------------- Step Court ----------------------------
      'select_trainer': 'ជ្រើសរើសគ្រូបង្វឹក',
      'select_court_desc':
          'ចុចលើទីលានដើម្បីជ្រើសរើស · ចុចរូបតំណាងពង្រីកដើម្បីមើល',
      'choose_trainer_desc': 'ជ្រើសរើសគ្រូបង្វឹកសម្រាប់វគ្គរបស់អ្នក',
      'pinch_to_zoom': 'ច្របាច់ដើម្បីពង្រីក',

      // ---------------------- Step Date & Time ----------------------------
      'choose_date_desc': 'ជ្រើសរើសកាលបរិច្ឆេទសម្រាប់ការកក់របស់អ្នក',
      'week_of': 'សប្តាហ៍នៃ {date}',
      'current_week': 'សប្តាហ៍បច្ចុប្បន្ន',
      'already_booked': 'បានកក់រួចហើយនៅលើទីលាននេះ',
      'from_label': 'ពី',
      'to_label': 'ទៅ',
      'pick_start_time_first': 'ជ្រើសរើសម៉ោងចាប់ផ្តើមជាមុនសិន',
      'no_available_end_times': 'គ្មានម៉ោងបញ្ចប់ដែលអាចរកបាន',
      'hours': 'ម៉ោង',

      // ---------------------- Days ----------------------------
      'mon': 'ចន្ទ',
      'tue': 'អង្គារ',
      'wed': 'ពុធ',
      'thu': 'ព្រហស្បតិ៍',
      'fri': 'សុក្រ',
      'sat': 'សៅរ៍',
      'sun': 'អាទិត្យ',

      // ---------------------- Months ----------------------------
      'jan': 'មករា',
      'feb': 'កុម្ភៈ',
      'mar': 'មីនា',
      'apr': 'មេសា',
      'may': 'ឧសភា',
      'jun': 'មិថុនា',
      'jul': 'កក្កដា',
      'aug': 'សីហា',
      'sep': 'កញ្ញា',
      'oct': 'តុលា',
      'nov': 'វិច្ឆិកា',
      'dec': 'ធ្នូ',

      // ---------------------- Step Payment ----------------------------
      'payment_method': 'វិធីសាស្ត្រទូទាត់',
      'choose_payment_desc': 'ជ្រើសរើសរបៀបដែលអ្នកចង់បង់ប្រាក់',
      'select_payment_section': 'ជ្រើសរើសការទូទាត់',
      'select_payment_method': 'សូមជ្រើសរើសវិធីសាស្ត្រទូទាត់',
      'contact_info_section': 'ព័ត៌មានទំនាក់ទំនង',
      'full_name_label': 'ឈ្មោះពេញ',
      'full_name_hint': 'បញ្ចូលឈ្មោះពេញរបស់អ្នក',
      'full_name_required': 'សូមបញ្ចូលឈ្មោះពេញរបស់អ្នក',
      'name_min_length': 'ឈ្មោះត្រូវតែមានយ៉ាងហោចណាស់ ២ តួអក្សរ',
      'phone_label': 'លេខទូរស័ព្ទ',
      'phone_hint': 'បញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
      'phone_required': 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
      'phone_invalid': 'សូមបញ្ចូលលេខទូរស័ព្ទដែលមានសុពលភាព',
      'sport': 'កីឡា',
      'time': 'ម៉ោង',
      'khqr_title': 'KHQR / ផ្ទេរតាមធនាគារ',
      'khqr_subtitle': 'ស្កេនកូដ QR ជាមួយកម្មវិធីធនាគារណាមួយនៅកម្ពុជា',
      'instant': 'ភ្លាមៗ',
      'cash_title': 'ទូទាត់ជាសាច់ប្រាក់',
      'cash_subtitle': 'បង់ប្រាក់នៅតុទទួលប្រាក់កន្លែង',
      'supported_banks': 'ធនាគារ និងកាបូបដែលគាំទ្រ',
      'khqr_step1': 'បើកកម្មវិធីធនាគាររបស់អ្នក ហើយចុច "ស្កេន QR"',
      'khqr_step2': 'ស្កេនកូដ KHQR ខាងលើ',
      'khqr_step3': 'បញ្ជាក់ចំនួនទឹកប្រាក់ និងបញ្ចប់ការផ្ទេរ',
      'khqr_step4': 'ចុច "បញ្ជាក់ និងមើលកូដ QR" ដើម្បីបញ្ចប់ការកក់របស់អ្នក',
      'amount_due': 'ចំនួនទឹកប្រាក់ត្រូវបង់នៅកន្លែង',
      'usd': 'ដុល្លារ',
      'cash_note':
          'សូមមកដល់ ១០ នាទីមុនម៉ោងកំណត់ ដើម្បីបង់ប្រាក់នៅតុទទួលប្រាក់មុនពេលវគ្គរបស់អ្នក',
      'cash_step1': 'ចុច "បញ្ជាក់ការកក់" ដើម្បីកក់ទីលានរបស់អ្នក',
      'cash_step2': 'មកដល់កន្លែងមុនពេលវគ្គរបស់អ្នក',
      'cash_step3': 'បង្ហាញការបញ្ជាក់ការកក់របស់អ្នកនៅតុទទួលប្រាក់',
      'cash_step4': 'បង់ប្រាក់ជាសាច់ប្រាក់ និងរីករាយជាមួយការប្រកួតរបស់អ្នក!',

      // ---------------------- Payment Success Page ----------------------------
      'payment_success_title': 'ការទូទាត់បានជោគជ័យ!',
      'payment_success_desc':
          'ទីលានរបស់អ្នកត្រូវបានកក់រួចរាល់។\nជួបគ្នានៅលើទីលាន!',
      'view_my_booking': 'មើលការកក់របស់ខ្ញុំ',
      'return_to_home': 'ត្រឡប់ទៅទំព័រដើម',
      'booking': 'ការកក់',
      'total_paid': 'បានបង់សរុប',

      // ---------------------- Password & Security ----------------------------
      'password_security': 'ពាក្យសម្ងាត់ និងសុវត្ថិភាព',
      'security_tips': 'គន្លឹះសុវត្ថិភាព',
      'strong_password_tip': 'ប្រើពាក្យសម្ងាត់រឹងមាំដែលមានអក្សរ លេខ និងសញ្ញា',
      'change_password_section': 'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
      'current_password': 'ពាក្យសម្ងាត់បច្ចុប្បន្ន',
      'new_password': 'ពាក្យសម្ងាត់ថ្មី',
      'confirm_new_password': 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
      'change_password': 'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
      'two_factor_auth': 'ការផ្ទៀងផ្ទាត់ពីរជាន់',
      'two_factor_desc': 'បន្ថែមស្រទាប់សុវត្ថិភាពបន្ថែម',
      'two_factor_coming_soon': '2FA នឹងមកដល់ឆាប់ៗនេះ',
      'enter_current_password': 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្ន',
      'enter_new_password': 'សូមបញ្ចូលពាក្យសម្ងាត់ថ្មី',
      'password_min_length': 'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងហោចណាស់ ៦ តួអក្សរ',
      'passwords_do_not_match': 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ',
      'password_changed_success': 'បានផ្លាស់ប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!',

      // ---------------------- Booked Detailed Screen ----------------------------
      'payment_summary': 'សេចក្តីសង្ខេបការទូទាត់',
      'field_booking': 'ការកក់ទីលាន',
      'service_fee': 'ថ្លៃសេវា',
      'total': 'សរុប',
      'booking_details': 'ពត៌មានលម្អិតការកក់',
      'status': 'ស្ថានភាព',
      'booked_on_date': 'បានកក់នៅថ្ងៃ',
      'cancellation_policy': 'គោលការណ៍បោះបង់ការកក់',
      'free_cancellation': 'បោះបង់ការកក់ដោយមិនគិតថ្លៃ',
      'free_cancellation_desc':
          'បោះបង់ការកក់មុន ២៤ ម៉ោង ដើម្បីទទួលបានសងប្រាក់វិញពេញលេញ',
      'late_cancellation': 'បោះបង់ការកក់យឺត',
      'late_cancellation_desc': 'ក្នុងរយៈពេល ២៤ ម៉ោង - គិតថ្លៃ ៥០% នៃតម្លៃកក់',
      'no_show': 'មិនបង្ហាញមុខ',
      'no_show_desc': 'គិតថ្លៃពេញ។ ទាក់ទងផ្នែកជំនួយប្រសិនបើអ្នកមានភាពបន្ទាន់',
      'scan_at_gate': 'ស្កេននៅមាត់ទ្វារ',
      'qr_instruction_detailed':
          'បង្ហាញកូដ QR នេះដល់បុគ្គលិកពេលមកដល់។ មានសុពលភាពសម្រាប់តែពេលវេលាដែលអ្នកបានកក់ប៉ុណ្ណោះ',
      'expires_in_days': 'ផុតកំណត់ក្នុងរយៈពេល ៣ ថ្ងៃ',
      'cancel_booking_warning':
          'តើអ្នកពិតជាចង់បោះបង់ការកក់នេះមែនទេ? អាចមានការគិតថ្លៃបោះបង់ការកក់',
      'no_keep_it': 'ទេ, រក្សាទុក',
      'yes_cancel': 'បាទ/ចាស, បោះបង់',
      'share_coming_soon': 'លក្ខណៈពិសេសចែករំលែកនឹងមកដល់ឆាប់ៗ',
      'hosted_by': 'រៀបចំដោយ {name}',
      'response_rate': 'អត្រាឆ្លើយតប: ៩៨%',

      // ---------------------- Authentication ----------------------------
      'login': 'ចូល',
      'sign_up': 'ចុះឈ្មោះ',
      'phone_or_username': 'លេខទូរស័ព្ទ ឬឈ្មោះអ្នកប្រើ',
      'password': 'ពាក្យសម្ងាត់',
      'confirm_password': 'បញ្ជាក់ពាក្យសម្ងាត់',
      'forgot_password': 'ភ្លេចពាក្យសម្ងាត់?',
      'remember_me': 'ចងចាំខ្ញុំ',
      'dont_have_account': 'មិនទាន់មានគណនី?',
      'already_have_account': 'មានគណនីរួចហើយ?',
      'verify_phone': 'ផ្ទៀងផ្ទាត់លេខទូរស័ព្ទរបស់អ្នក',
      'enter_otp': 'បញ្ចូលលេខកូដ ៦ ខ្ទង់ដែលផ្ញើទៅកាន់ទូរស័ព្ទរបស់អ្នក',
      'resend_code': 'មិនបានទទួលកូដ?',
      'resend': 'ផ្ញើម្តងទៀត',
      'verify': 'ផ្ទៀងផ្ទាត់',
      'welcome_back': 'សូមស្វាគមន៍មកកាន់! សូមចូលដើម្បីបន្ត',
      'valid_phone_required': 'សូមបញ្ចូលលេខទូរស័ព្ទដែលមានសុពលភាព',
      'password_hint': 'បញ្ចូលពាក្យសម្ងាត់របស់អ្នក',
      'password_required': 'តម្រូវឱ្យបញ្ចូលពាក្យសម្ងាត់',
      'create_account_desc': 'បង្កើតគណនីរបស់អ្នកដើម្បីចាប់ផ្តើម',
      'phone': 'លេខទូរស័ព្ទ',
      'confirm_password_required': 'សូមបញ្ជាក់ពាក្យសម្ងាត់របស់អ្នក',
      'confirm_password_hint': 'បញ្ជាក់ពាក្យសម្ងាត់របស់អ្នក',
      'password_mismatch': 'ពាក្យសម្ងាត់មិនត្រូវគ្នា',
      'reset_password_desc': 'កំណត់ពាក្យសម្ងាត់របស់អ្នកឡើងវិញ',
      'reset_password': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
      'remembered_password': 'ចងចាំពាក្យសម្ងាត់របស់អ្នក?',
      'resend_in': 'ផ្ញើម្តងទៀតក្នុងរយៈពេល {seconds} វិនាទី',
      'back_to': 'ត្រឡប់ទៅ ',
      'email_phone_username': 'អ៊ីមែល លេខទូរស័ព្ទ ឬឈ្មោះអ្នកប្រើ',
      'email_phone_username_hint':
          'បញ្ចូលអ៊ីមែល លេខទូរស័ព្ទ ឬឈ្មោះអ្នកប្រើរបស់អ្នក',
      'identifier_required': 'តម្រូវឱ្យបញ្ចូលអ៊ីមែល លេខទូរស័ព្ទ ឬឈ្មោះអ្នកប្រើ',
      'invalid_email_format':
          'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលដែលមានសុពលភាព (ឧទាហរណ៍ user@example.com)',
      'invalid_phone_format':
          'សូមបញ្ចូលលេខទូរស័ព្ទកម្ពុជាដែលមានសុពលភាព (ឧទាហរណ៍ ០១២៣៤៥៦៧៨៩, ៨៥៥១២៣៤៥៦៧៨, +៨៥៥១២៣៤៥៦៧៨)',
      'invalid_phone_length':
          'លេខទូរស័ព្ទត្រូវតែមាន ៩-១០ ខ្ទង់បន្ទាប់ពីកូដប្រទេស',
      'username_too_short': 'ឈ្មោះអ្នកប្រើត្រូវតែមានយ៉ាងហោចណាស់ ៣ តួអក្សរ',
      'username_too_long': 'ឈ្មោះអ្នកប្រើត្រូវតែតិចជាង ៣០ តួអក្សរ',
      'invalid_identifier':
          'សូមបញ្ចូលអ៊ីមែល លេខទូរស័ព្ទ ឬឈ្មោះអ្នកប្រើដែលមានសុពលភាព (អក្សរ លេខ ចំនុច គូសក្រោម)',
      'login_success': 'ការចូលបានជោគជ័យ!',
      'login_failed': 'ការចូលបរាជ័យ។ សូមពិនិត្យមើលព័ត៌មានសម្គាល់របស់អ្នក',

      // ---------------------- Create Profile Screen ----------------------------
      'choose_photo': 'ជ្រើសរើសរូបថត',
      'choose_from_library': 'ជ្រើសរើសពីបណ្ណាល័យ',
      'take_a_photo': 'ថតរូប',
      'remove_photo': 'លុបរូបថត',
      'create_profile_title': 'បង្កើតប្រវត្តិរូបរបស់អ្នក',
      'create_profile_desc':
          'កំណត់ប្រវត្តិរូបរបស់អ្នកដើម្បីឱ្យអ្នកលេងផ្សេងទៀត\nអាចស្វែងរក និងភ្ជាប់ជាមួយអ្នកបាន',
      'username': 'ឈ្មោះអ្នកប្រើ',
      'username_required': 'តម្រូវឱ្យបញ្ចូលឈ្មោះអ្នកប្រើ',
      'username_min_length': 'ឈ្មោះអ្នកប្រើត្រូវមានយ៉ាងហោចណាស់ ៣ តួអក្សរ',
      'username_no_spaces': 'ឈ្មោះអ្នកប្រើមិនអាចមានដកឃ្លាបានទេ',
      'username_hint': 'ឧទាហរណ៍ john_doe',
      'email': 'អ៊ីមែល',
      'optional': 'ស្រេចចិត្ត',
      'email_hint': 'your@email.com',
      'valid_email_required': 'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលដែលមានសុពលភាព',
      'create_profile': 'បង្កើតប្រវត្តិរូប',
      'skip_for_now': 'រំលងសម្រាប់ពេលនេះ',

      // ---------------------- Messages ----------------------------
      'booking_cancelled': 'បានបោះបង់ការកក់ដោយជោគជ័យ',
      'profile_updated': 'បានធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូបដោយជោគជ័យ',
      'password_changed': 'បានផ្លាស់ប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ',
      'all_notifications_read': 'បានសម្គាល់ការជូនដំណឹងទាំងអស់ថាបានអាន',

      // ---------------------- Time ----------------------------
      'tomorrow': 'ថ្ងៃស្អែក',
      'yesterday': 'ម្សិលមិញ',

      // ---------------------- Status ----------------------------
      'confirmed': 'បានបញ្ជាក់',
      'pending': 'កំពុងរង់ចាំ',
      'cancelled': 'បានបោះបង់',

      // ---------------------- Landing Screen ----------------------------
      'banner_title_1': 'កក់កីឡា\nរបស់អ្នកថ្ងៃនេះ!',
      'banner_title_2': 'ស្វែងរកទីលាន\nភ្លាមៗ',
      'banner_title_3': 'ជួប និងលេង\nជាមួយអ្នកដទៃ',
      'banner_title_4': 'តាមដាន\nការអនុវត្តន៍',
      'banner_desc_1':
          'ស្វែងរកទីលាន កក់ពេលវេលា និងភ្ជាប់ជាមួយអ្នកលេងក្បែរអ្នក — ទាំងអស់នៅកន្លែងតែមួយ។',
      'banner_desc_2':
          'ស្វែងរកទីលានបាល់បោះដែលមាន ពិនិត្យមើលភាពអាចរកបានតាមពេលវេលាជាក់ស្តែង និងកក់ក្នុងរយៈពេលប៉ុន្មានវិនាទី។',
      'banner_desc_3':
          'ចូលរួមការប្រកួតក្នុងតំបន់ ប្រកួតប្រជែងជាមួយអ្នកលេងក្បែរអ្នក និងពង្រីកសហគមន៍កីឡារបស់អ្នក។',
      'banner_desc_4':
          'កត់ត្រាវគ្គរបស់អ្នក តាមដានវឌ្ឍនភាព និងបង្កើនសមត្ថភាពផ្ទាល់ខ្លួនរាល់ពេលដែលអ្នកលេង។',
    },
  };

  // ============================================================================
  // Public Methods
  // ============================================================================

  /// Translates a given key to the specified locale.
  /// If the translation is not found, falls back to English or returns the key itself.
  static String translate(String key, {String? locale}) {
    final languageCode = locale ?? 'en';
    final translation = _translations[languageCode]?[key];

    if (translation == null) {
      // Log missing translations for debugging
      debugPrint(
        'Missing translation for key: $key in language: $languageCode',
      );
      return _translations['en']?[key] ?? key;
    }

    return translation;
  }
}

// ============================================================================
// String Extension for Convenient Translation
// ============================================================================

/// Extension on String to easily translate text using BuildContext.
///
/// Usage: 'hello'.tr(context)
extension StringTranslation on String {
  String tr(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return AppTranslations.translate(
      this,
      locale: languageProvider.currentLanguage,
    );
  }
}
