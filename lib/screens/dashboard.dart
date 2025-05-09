import 'package:echo_trail/screens/setting.dart';
import 'package:echo_trail/screens/speech_text.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.speech,
    Permission.scheduleExactAlarm,
  ].request();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Define the colors used in the design
  static const Color lightBlueBackground = Color(
    0xFFE3F2FD,
  ); // A light blue color
  static const Color darkBlueCard = Color(
    0xFF10164D,
  ); // A deep indigo/dark blue
  static const Color whiteText = Colors.white;
  static const Color redDot = Colors.red;
  static const Color tealAccent = Color(
    0xFF64FFDA,
  ); // A bright teal for the graphic

  @override
  Widget build(BuildContext context) {
    requestPermissions();
    return Scaffold(
      backgroundColor: lightBlueBackground,
      body: SafeArea(
        // Ensures content is below status bar
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch cards horizontally
            children: <Widget>[
              // Header Card
              HeaderCard(name: 'Umar', date: '01 January  2025'),
              const SizedBox(height: 16.0),
              NavigationCard(), // Space between cards
              // Navigation Card
              const SizedBox(height: 16.0), // Space between cards
              // Belt Tracking Card
              BeltTrackingCard(),
              const SizedBox(height: 16.0), // Space between cards
              // Alarm Card
              AlarmCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Widget for the Header Card
class HeaderCard extends StatelessWidget {
  final String name;
  final String date;

  const HeaderCard({super.key, required this.name, required this.date});

  static const Color darkBlueCard = Color(0xFF10164D);
  static const Color whiteText = Colors.white;
  static const Color tealAccent = Color(
    0xFF64FFDA,
  ); // A bright teal for the graphic

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        decoration: BoxDecoration(
          color: darkBlueCard,
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        child: Stack(
          // Use Stack to place the graphic behind the text
          children: [
            // Background Graphic (Simplified representation)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Row(
                // Using a Row to place circles next to each other
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 20),
                  // 2. Use the CustomPainter in your widget tree
                  SizedBox(
                    width: 120, // Adjust size as needed
                    height: 130, // Adjust size as needed
                    child: CustomPaint(
                      // You can provide an explicit size to the painter
                      size: Size(70, 60),
                      // Or let it take the size from the parent Container
                      // size: Size.infinite,
                      painter: ConcentricArcPainter(),
                    ),
                  ),
                ],
              ),
            ),
            // Text and Icon Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Keep column size minimal
              children: <Widget>[
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: whiteText.withOpacity(
                          0.8,
                        ), // Slightly less opaque
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 900,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SettingsScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.settings_outlined, // Settings icon
                        // ignore: deprecated_member_use
                        color: whiteText.withOpacity(0.8),
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Widget for the Feature Cards
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? status; // Optional status text (like Disconnected or time)
  final Color statusColor; // Optional color for the status text/dot

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.status,
    this.statusColor = Colors.white, // Default status color is white
  });

  static const Color darkBlueCard = Color(0xFF10164D);
  static const Color whiteText = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: darkBlueCard,
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: <Widget>[
          Icon(
            icon,
            color: whiteText,
            size: 40.0, // Adjust icon size
          ),
          const SizedBox(width: 20.0), // Space between icon and text
          Expanded(
            // Allows text to take up remaining space and wrap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (status != null) ...[
                  // Add status row if status is provided
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      if (statusColor ==
                          Colors.red) // Add red dot if status is red
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.only(right: 4.0),
                        ),
                      Text(
                        status!,
                        style: TextStyle(
                          color: statusColor, // Use provided status color
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(
                  height: 8.0,
                ), // Space between title/status and description
                Text(
                  description,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: whiteText.withOpacity(0.8), // Slightly less opaque
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConcentricArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // --- Configuration ---
    final Color outerArcColor = Color(0xFFaab1c9); // Pale lavender/grey
    final Color innerArcColor = Color(0xFF4e8c97); // Teal/blue-green

    // Adjust stroke width if needed (might look better slightly thinner)
    final double strokeWidth = 15.0; // Let's try 8.0

    // Center remains the same
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = size.width * 0.46; // e.g., 43% of the way out
    final double innerRadius = size.width * 0.27; // e.g., 25% of the way out

    final Paint outerPaint =
        Paint()
          ..color = outerArcColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt; // Use .round for rounded ends

    final Paint innerPaint =
        Paint()
          ..color = innerArcColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt; // Use .round for rounded ends
    final double sweepAngle =
        4.7; // Radians (~260 degrees) Adjust slightly if needed

    // --- Drawing ---
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    canvas.drawArc(outerRect, -4.9, sweepAngle, false, outerPaint);
    canvas.drawArc(innerRect, -3.3, 3.1, false, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class NavigationCard extends StatelessWidget {
  // Define the specific dark blue color from the image
  final Color cardBackgroundColor = const Color(0xFF10164D); // Adjust if needed
  final String iconPath = 'assets/images/navigation.png';

  const NavigationCard({super.key}); // Make sure this path is correct

  @override
  Widget build(BuildContext context) {
    return Container(
      // Constrain the width if necessary, otherwise it will expand
      // width: 350, // Example fixed width
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.0), // Adjust rounding as needed
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 28.0,
      ), // Adjust padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align content to the left
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align icon top with text top
            children: [
              // Icon
              Image.asset(iconPath),
              const SizedBox(width: 45.0), // Space between icon and text
              // Title Text - Expanded allows text wrapping
              Expanded(
                child: Text(
                  'Navigation and\nObstacle\nGuidance', // Use \n for line breaks
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0, // Adjust font size
                    fontWeight: FontWeight.bold,
                    height: 1.3, // Adjust line spacing
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ), // Space between title row and description
          // Description Text
          Center(
            child: Text(
              textAlign: TextAlign.center,
              'Allowing users to navigate their path freely', // Corrected "their"
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(
                  0.9,
                ), // Slightly transparent white
                fontSize: 14.0, // Adjust font size
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BeltTrackingCard extends StatelessWidget {
  // Define colors matching the image
  final Color cardBackgroundColor = const Color(0xFF10164D); // Same dark blue
  final Color statusDotColor = Colors.red; // Red dot for disconnected status
  final String iconPath = 'assets/images/seat-belt.png';

  const BeltTrackingCard({super.key}); // MAKE SURE THIS PATH IS CORRECT

  @override
  Widget build(BuildContext context) {
    return Container(
      // Constrain width if needed
      // width: 350,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.0), // Adjust rounding
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 28.0,
      ), // Adjust padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fit content vertically
        crossAxisAlignment: CrossAxisAlignment.start, // Align content left
        children: [
          // Top Section: Icon + Title/Status
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align icon top with text block top
            children: [
              // Icon
              Image.asset(iconPath, color: Colors.white),
              const SizedBox(width: 45.0), // Space between icon and text block
              // Title and Status Column
              // Use Expanded to prevent potential overflow issues if text is long
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text left
                  children: [
                    // Title Text
                    Text(
                      'Belt Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0, // Adjust font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ), // Space between title and status
                    // Status Row (Dot + Text)
                    Row(
                      // Vertically center the dot and the status text
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Status Dot
                        Container(
                          width: 12.0, // Adjust dot size
                          height: 12.0, // Adjust dot size
                          decoration: BoxDecoration(
                            color: statusDotColor,
                            shape: BoxShape.circle, // Make it circular
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ), // Space between dot and text
                        // Status Text
                        Text(
                          'Disconnected',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.red.withOpacity(
                              0.9,
                            ), // Slightly transparent white
                            fontSize: 16.0, // Adjust font size
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ), // Space between top section and description
          // Description Text
          Center(
            child: Text(
              'Belt tracking for users to track their navigation belt', // Corrected "their"
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(
                  0.9,
                ), // Slightly transparent white
                fontSize: 14.0, // Adjust font size
                height: 1.4, // Adjust line spacing if needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmCard extends StatelessWidget {
  // Define colors matching the image
  final Color cardBackgroundColor = const Color(0xFF10164D); // Same dark blue
  final Color statusDotColor = Colors.red; // Red dot for disconnected status
  final String iconPath = 'assets/images/alarm.png';

  const AlarmCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Constrain width if needed
      // width: 350,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.0), // Adjust rounding
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 28.0,
      ), // Adjust padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fit content vertically
        crossAxisAlignment: CrossAxisAlignment.start, // Align content left
        children: [
          // Top Section: Icon + Title/Status
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align icon top with text block top
            children: [
              // Icon
              Image.asset(iconPath, color: Colors.white),
              const SizedBox(width: 45.0), // Space between icon and text block
              // Title and Status Column
              // Use Expanded to prevent potential overflow issues if text is long
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text left
                  children: [
                    // Title Text
                    Text(
                      'Set and Shut Alarm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0, // Adjust font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ), // Space between title and status
                    // Status Row (Dot + Text)
                    Row(
                      // Vertically center the dot and the status text
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Status Dot
                        // Container(
                        //   width: 12.0, // Adjust dot size
                        //   height: 12.0, // Adjust dot size
                        //   decoration: BoxDecoration(
                        //     color: statusDotColor,
                        //     shape: BoxShape.circle, // Make it circular
                        //   ),
                        // ),
                        const SizedBox(width: 0), // Space between dot and text
                        // Status Text
                        Text(
                          '7:30 pm',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(
                              0.9,
                            ), // Slightly transparent white
                            fontSize: 16.0, // Adjust font size
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ), // Space between top section and description
          // Description Text
          Center(
            child: Text(
              'Allowing users to set and shut there alarm via voice guidance', // Corrected "their"
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(
                  0.9,
                ), // Slightly transparent white
                fontSize: 14.0, // Adjust font size
                height: 1.4, // Adjust line spacing if needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
