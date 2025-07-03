import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth <= 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green[800]!,
            Colors.green[900]!,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content section
          isMobile ? _buildMobileLayout() : _buildDesktopLayout(),

          SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white30,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Bottom section
          isMobile ? _buildMobileBottomSection() : _buildDesktopBottomSection(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandCard(),
        SizedBox(height: 16),
        _buildContactCard(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _buildBrandCard()),
          SizedBox(width: 20),
          Expanded(flex: 2, child: _buildContactCard()),
        ],
      ),
    );
  }

  Widget _buildBrandCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[700]!.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Terarium Shop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Crafting nature-inspired terrariums for your home and office. Bringing the beauty of nature indoors with carefully curated plants and sustainable materials.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[700]!.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email_outlined,
            text: 'support@terariumshop.com',
          ),
          SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.phone_outlined,
            text: '+84 123 456 789',
          ),
          SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.location_on_outlined,
            text: 'Thuận An, Bình Dương, Vietnam',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomSection() {
    return Column(
      children: [
        // Social media icons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.facebook, () {}),
            SizedBox(width: 16),
            _buildSocialIcon(FontAwesomeIcons.instagram, () {}),
            SizedBox(width: 16),
            _buildSocialIcon(FontAwesomeIcons.youtube, () {}),
            SizedBox(width: 16),
            _buildSocialIcon(FontAwesomeIcons.tiktok, () {}),
          ],
        ),
        SizedBox(height: 16),
        // Copyright text
        Text(
          '© 2025 Terarium Shop',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'All rights reserved',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBottomSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© 2025 Terarium Shop. All rights reserved.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook, () {}),
            SizedBox(width: 12),
            _buildSocialIcon(FontAwesomeIcons.instagram, () {}),
            SizedBox(width: 12),
            _buildSocialIcon(FontAwesomeIcons.youtube, () {}),
            SizedBox(width: 12),
            _buildSocialIcon(FontAwesomeIcons.tiktok, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        onPressed: onPressed,
        splashRadius: 20,
        tooltip: 'Follow us',
      ),
    );
  }
}
