import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Helper method to get responsive values based on screen width
  double getResponsiveValue(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return mobile;
    } else if (screenWidth < 1200) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Helper method to get responsive padding
  EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
    } else if (screenWidth < 1200) {
      return const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 80.0, vertical: 32.0);
    }
  }

  // Helper method to determine if device is in landscape mode
  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width >= 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          'Warehouse Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: getResponsiveValue(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        toolbarHeight: getResponsiveValue(
          context,
          mobile: 56,
          tablet: 64,
          desktop: 72,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: getResponsivePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height - 
                         AppBar().preferredSize.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: isTabletOrDesktop && !isLandscape(context)
                ? _buildTabletDesktopLayout(context)
                : _buildMobileLayout(context),
          ),
        ),
      ),
    );
  }

  // Mobile layout - centered column
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildWelcomeIcon(context),
        SizedBox(
          height: getResponsiveValue(
            context,
            mobile: 20,
            tablet: 30,
            desktop: 40,
          ),
        ),
        _buildWelcomeText(context),
        SizedBox(
          height: getResponsiveValue(
            context,
            mobile: 10,
            tablet: 15,
            desktop: 20,
          ),
        ),
        _buildDescriptionText(context),
        SizedBox(
          height: getResponsiveValue(
            context,
            mobile: 30,
            tablet: 40,
            desktop: 50,
          ),
        ),
        _buildActionButtons(context),
      ],
    );
  }

  // Tablet/Desktop layout - side by side or card-based
  Widget _buildTabletDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Card(
          elevation: 4,
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              getResponsiveValue(
                context,
                mobile: 24,
                tablet: 32,
                desktop: 48,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWelcomeIcon(context),
                SizedBox(
                  height: getResponsiveValue(
                    context,
                    mobile: 30,
                    tablet: 40,
                    desktop: 50,
                  ),
                ),
                _buildWelcomeText(context),
                SizedBox(
                  height: getResponsiveValue(
                    context,
                    mobile: 15,
                    tablet: 20,
                    desktop: 25,
                  ),
                ),
                _buildDescriptionText(context),
                SizedBox(
                  height: getResponsiveValue(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Responsive welcome icon
  Widget _buildWelcomeIcon(BuildContext context) {
    return Icon(
      Icons.warehouse,
      size: getResponsiveValue(
        context,
        mobile: 80,
        tablet: 120,
        desktop: 150,
      ),
      color: const Color(0xFF3B82F6),
    );
  }

  // Responsive welcome text
  Widget _buildWelcomeText(BuildContext context) {
    return Text(
      'Welcome to Warehouse Management App!',
      style: TextStyle(
        fontSize: getResponsiveValue(
          context,
          mobile: 20,
          tablet: 28,
          desktop: 32,
        ),
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Responsive description text
  Widget _buildDescriptionText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getResponsiveValue(
          context,
          mobile: 0,
          tablet: 20,
          desktop: 40,
        ),
      ),
      child: Text(
        'Your warehouse management journey starts here. Streamline operations, track inventory, and boost efficiency.',
        style: TextStyle(
          fontSize: getResponsiveValue(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
          color: Colors.grey[400],
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Responsive action buttons
  Widget _buildActionButtons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      // Mobile: Stack buttons vertically
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to inventory or main features
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                // Show app info or tutorial
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    } else {
      // Tablet/Desktop: Place buttons side by side
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to inventory or main features
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 160,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                // Show app info or tutorial
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }
  }
}
