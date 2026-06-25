// screens/settings/features/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy & Policy',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(isDark),
              const SizedBox(height: 24),

              // About App Section
              _buildAboutApp(isDark),
              const SizedBox(height: 24),

              // Data Collection Section
              _buildDataCollection(isDark),
              const SizedBox(height: 24),

              // Permissions Section
              _buildPermissions(isDark),
              const SizedBox(height: 24),

              // Data Storage & Security
              _buildDataStorage(isDark),
              const SizedBox(height: 24),

              // Your Rights
              _buildYourRights(isDark),
              const SizedBox(height: 24),

              // Contact Section
              _buildContact(isDark),
              const SizedBox(height: 32),

              // Last Updated
              _buildLastUpdated(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.kAccent.withValues(alpha: 0.15),
            AppTheme.kAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.kAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.kAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppTheme.kAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'We are committed to protecting your personal data',
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutApp(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.info_outline_rounded,
      title: 'About SportMate',
      content: '''
SportMate is Cambodia's leading sports booking platform that connects athletes and sports enthusiasts with world-class sports facilities across the country. Our mission is to make sports accessible to everyone by providing a seamless, convenient, and secure platform for booking courts, finding training partners, and tracking performance.

Whether you're a casual player looking for a weekend game or a competitive athlete training for championships, SportMate offers a comprehensive solution to meet all your sports needs. We partner with hundreds of sports facilities across Cambodia to bring you the best selection of courts and training programs.

Our app is designed with your convenience in mind - from real-time court availability to instant booking confirmations and secure payment processing. We're constantly working to improve your experience and expand our network of partner facilities.

**What We Offer:**
• Easy court booking in seconds
• Real-time availability checks
• Secure online payments
• Track your booking history
• Connect with other players
• Find training partners
• Access to exclusive promotions
• 24/7 customer support

**Our Values:**
• Transparency in all our operations
• Commitment to user privacy
• Continuous innovation
• Community building through sports
• Accessibility for all''',
    );
  }

  Widget _buildDataCollection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.data_usage_rounded,
      title: 'What Data We Collect',
      content: '''
To provide you with the best possible experience, we collect the following types of information:

**Account Information:**
• Full name and username
• Email address and phone number
• Profile photo (optional)
• Date of birth (for age verification)
• Preferred sports and skill levels

**Usage Data:**
• Booking history and preferences
• Facility ratings and reviews
• Search queries and filters
• Pages visited and time spent
• App interactions and features used

**Device Information:**
• Device type and model
• Operating system version
• App version and build number
• Device identifiers
• IP address and network information

**Payment Information:**
• We do NOT store your full payment card details
• All payments are processed through secure third-party providers
• We only store transaction references and payment confirmations

**How We Use Your Data:**
• To process and manage your bookings
• To improve our services and user experience
• To send you booking confirmations and reminders
• To notify you about upcoming events and promotions
• To provide customer support and resolve issues
• To analyze trends and improve our platform
• To personalize your experience and recommendations''',
    );
  }

  Widget _buildPermissions(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.security_rounded,
      title: 'Permissions We Use',
      content: '''
We only request permissions that are essential for providing our services. Here's why we need each permission:

**Location Permission**

**Why We Need It:**
• To find sports facilities near you
• To show real-time distance to courts
• To suggest nearby training partners
• To provide accurate travel directions
• To display local events and promotions

**How We Use It:**
• We only access your location when you search for nearby facilities
• Your location is never shared with third parties
• You can manually enter your location if you prefer not to share

**Camera Permission**

**Why We Need It:**
• To upload profile photos
• To scan QR codes for entry passes
• To take photos of your achievements
• To share your sports moments with friends

**How We Use It:**
• The camera is only activated when you explicitly use it
• Photos are only uploaded if you choose to share them
• QR codes are scanned only for entry verification

**Gallery/Storage Permission**

**Why We Need It:**
• To select profile photos from your gallery
• To download and save booking confirmations
• To share booking receipts and passes
• To upload sports achievements and photos

**How We Use It:**
• We only access files you explicitly select
• Downloaded files are stored in your device's secure storage
• We don't access other files on your device

**Notification Permission**

**Why We Need It:**
• To send booking confirmations and reminders
• To notify you about upcoming events
• To alert you about special promotions
• To inform you about booking status changes

**How We Use It:**
• You can opt out of notifications at any time
• We never send spam or unwanted notifications
• You control what notifications you receive''',
    );
  }

  Widget _buildDataStorage(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.storage_rounded,
      title: 'Data Storage & Security',
      content: '''
**How We Protect Your Data:**
• All data is encrypted during transmission using SSL/TLS
• Your passwords are hashed and never stored in plain text
• We use industry-standard security protocols
• Regular security audits and updates
• Access to data is restricted to authorized personnel only

**Data Storage:**
• Your data is stored on secure servers in Cambodia
• We retain your data only as long as necessary
• You can request data deletion at any time
• Backups are encrypted and stored securely

**Data Sharing:**
• We never sell your personal data to third parties
• Data is shared only with your consent
• We share minimal data with service providers (payments, notifications)
• All service providers are bound by strict confidentiality agreements

**Children's Privacy:**
• We do not knowingly collect data from children under 13
• Parental consent is required for users under 18
• We encourage parental supervision of app usage''',
    );
  }

  Widget _buildYourRights(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.gavel_rounded,
      title: 'Your Rights',
      content: '''
You have full control over your personal data:

**Access:** You can view all data we hold about you at any time.

**Correction:** You can update or correct your personal information.

**Deletion:** You can request deletion of your account and personal data.

**Portability:** You can request a copy of your data in a portable format.

**Restriction:** You can limit how we use your data for specific purposes.

**Objection:** You can object to certain types of data processing.

**Withdraw Consent:** You can withdraw consent at any time.

**How to Exercise Your Rights:**
1. Go to Settings → Profile → Edit Profile
2. Use the Account Management section
3. Contact us at support@sportmate.com
4. We will respond within 30 days''',
    );
  }

  Widget _buildContact(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.contact_support_rounded,
      title: 'Contact Us',
      content: '''
If you have any questions about our privacy policy or how we handle your data, please don't hesitate to contact us:

**Email:** privacy@sportmate.com
**Phone:** +855 12 345 678
**Address:** 123, Street 456, Phnom Penh, Cambodia

**Working Hours:** 
Monday - Friday: 8:00 AM - 6:00 PM
Saturday: 8:00 AM - 4:00 PM
Sunday: Closed

We aim to respond to all privacy-related inquiries within 24-48 hours.

**Data Protection Officer:**
Mr. Sok Dara
Email: dpo@sportmate.com
Phone: +855 12 345 679''',
    );
  }

  Widget _buildLastUpdated(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Text(
              'Last Updated: June 25, 2026',
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.kAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
