// screen\setting.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:permission_handler/permission_handler.dart'; // Import the package
import 'dart:io' show Platform;

// Define colors from the design
const Color primaryBlue = Color(0xFF10164D);
const Color backgroundColor = Color(0xFFDFEBF6);
const Color switchInactiveColor =
    Colors.grey; // Or a specific grey if preferred
const Color inputBackgroundColor = Color(
  0xFFBDBDBD,
); // Approximation for grey input bg

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

// Add WidgetsBindingObserver mixin to listen for app lifecycle changes
class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  // --- State Variables ---
  // Use PermissionStatus or bool derived from it
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _gpsStatus = PermissionStatus.denied;
  PermissionStatus _micStatus =
      PermissionStatus.denied; // Speaker linked to Mic for demo
  PermissionStatus _alarmStatus =
      PermissionStatus.denied; // Linked to Notification/ExactAlarm
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  PermissionStatus _messagesStatus = PermissionStatus.denied; // SMS
  PermissionStatus _bluetoothStatus =
      PermissionStatus.denied; // Combined BT status

  // Internal app settings (not OS permissions)
  bool _isBatterySettingEnabled = true; // Keep as internal toggle state
  late TextEditingController _batteryController;

  @override
  void initState() {
    super.initState();
    _batteryController = TextEditingController(text: '30');
    WidgetsBinding.instance.addObserver(this); // Register observer
    _checkInitialPermissions(); // Check statuses on screen load
  }

  @override
  void dispose() {
    _batteryController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Unregister observer
    super.dispose();
  }

  // --- Lifecycle Listener ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Re-check permissions when the app resumes (e.g., after returning from settings)
      //print("App resumed, re-checking permissions.");
      _checkInitialPermissions();
    }
  }

  // --- Permission Handling ---

  Future<void> _checkInitialPermissions() async {
    // Define permissions to check
    List<Permission> permissionsToCheck = [
      Permission.camera,
      Permission.location, // Or locationWhenInUse / locationAlways
      Permission.microphone,
      _getAlarmPermission(), // Platform-specific alarm permission
      Permission.notification,
      Permission.sms,
      _getBluetoothPermission(), // Platform-specific BT permission
    ];

    // Request statuses for all permissions
    Map<Permission, PermissionStatus> statuses =
        await permissionsToCheck.request();

    // Update state only if the widget is still mounted
    if (mounted) {
      setState(() {
        _cameraStatus = statuses[Permission.camera] ?? PermissionStatus.denied;
        _gpsStatus = statuses[Permission.location] ?? PermissionStatus.denied;
        _micStatus = statuses[Permission.microphone] ?? PermissionStatus.denied;
        _alarmStatus =
            statuses[_getAlarmPermission()] ?? PermissionStatus.denied;
        _notificationStatus =
            statuses[Permission.notification] ?? PermissionStatus.denied;
        _messagesStatus = statuses[Permission.sms] ?? PermissionStatus.denied;
        _bluetoothStatus =
            statuses[_getBluetoothPermission()] ?? PermissionStatus.denied;
      });
      //print("Checked Initial Statuses: $statuses"); // For debugging
    }
  }

  // Helper to get platform-specific Alarm permission
  Permission _getAlarmPermission() {
    if (Platform.isAndroid) {
      // Using notification as a stand-in due to complexity of SCHEDULE_EXACT_ALARM handling
      return Permission.notification;
      // return Permission.scheduleExactAlarm; // Use this if handling specific Android 12+ logic
    } else {
      // iOS uses notifications for alarm-like features
      return Permission.notification;
    }
  }

  // Helper to get platform-specific Bluetooth permission
  // Simplified: Real apps might need multiple BT permissions (scan, connect, advertise)
  Permission _getBluetoothPermission() {
    if (Platform.isAndroid) {
      // Use bluetoothConnect on Android 12+ (API 31+), otherwise handle older BT permissions
      // For simplicity, we'll target connect here. Requires BLUETOOTH_CONNECT in Manifest.
      return Permission.bluetoothConnect;
      // Alternatively consider Permission.bluetoothScan if discovery is the primary need
    } else {
      // permission_handler usually maps general BT usage on iOS to this.
      // Requires NSBluetoothPeripheralUsageDescription or NSBluetoothAlwaysUsageDescription in Info.plist
      return Permission.bluetooth;
    }
  }

  // Requests a single permission if not already granted or permanently denied
  Future<void> _requestPermission(Permission permission) async {
    // Check current status first, might not need to request if already granted
    PermissionStatus currentStatus = await permission.status;
    if (currentStatus.isGranted || currentStatus.isLimited) {
      //print("$permission already granted.");
      return; // No need to request again
    }

    final status = await permission.request();
    //print("Status after request for $permission: $status"); // Debugging

    // Update state only if the widget is still mounted
    if (mounted) {
      setState(() {
        // Update the specific status variable based on the permission requested
        if (permission == Permission.camera) _cameraStatus = status;
        if (permission == Permission.location) _gpsStatus = status;
        if (permission == Permission.microphone) _micStatus = status;
        if (permission == _getAlarmPermission()) _alarmStatus = status;
        if (permission == Permission.notification) _notificationStatus = status;
        if (permission == Permission.sms) _messagesStatus = status;
        if (permission == _getBluetoothPermission()) _bluetoothStatus = status;
      });
    }

    if (status.isPermanentlyDenied) {
      // Inform user they need to go to settings
      _showSettingsDialog(
        permission.toString().split('.').last,
      ); // Show friendly permission name
    }
    // Add any special handling needed for specific permissions post-request if required
  }

  // Shows dialog prompting user to go to OS Settings
  void _showSettingsDialog(String permissionName) {
    // Ensure dialog is shown only if context is available
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text(
              '${permissionName.toUpperCase()} permission has been permanently denied or needs to be changed in system settings. Please enable it in App Settings.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Open Settings'),
                onPressed: () {
                  openAppSettings(); // Provided by permission_handler
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  // Helper to get user-friendly subtitle based on permission status
  String _getSubtitleForStatus(PermissionStatus status, String featureName) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Allowed';
      case PermissionStatus.denied:
        // Check if it's a permission that hasn't been requested yet
        return 'Not determined - Tap to request'; // More accurate than just 'Denied' initially
      case PermissionStatus.restricted:
        return 'Restricted (e.g., parental controls)';
      case PermissionStatus.limited: // e.g., iOS photo access
        return 'Limited Access - Tap to change';
      case PermissionStatus.permanentlyDenied:
        return 'Denied - Tap to open Settings';
      default:
        return 'Unknown status';
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // Mimic the status bar area without an actual AppBar
        toolbarHeight: 0, // Hide the default AppBar
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          // Make status bar icons visible on light background
          statusBarIconBrightness: Brightness.dark, // For Android
          statusBarBrightness: Brightness.light, // For iOS
          statusBarColor: backgroundColor, // Match Scaffold background
        ),
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        // Ensures content isn't hidden by notches or status bar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Text(
                'Settings',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 36, // Adjust size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your Personalization and Permissions to the app appears here',
                style: TextStyle(
                  color:
                      Colors.black87, // Slightly less intense than pure black
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 30), // Space before the list
              // --- Settings List ---
              Expanded(
                // Allow the list to take remaining space and potentially scroll
                child: ListView(
                  // Use ListView for potential scrolling
                  children: [
                    _buildPermissionToggle(
                      title: 'Camera Access',
                      permission: Permission.camera,
                      status: _cameraStatus,
                    ),
                    _buildPermissionToggle(
                      title: 'GPS',
                      permission: Permission.location,
                      status: _gpsStatus,
                    ),
                    _buildPermissionToggle(
                      title:
                          'Speaker / Mic', // UI label needs clarity vs actual permission
                      permission: Permission.microphone,
                      status: _micStatus,
                    ),
                    _buildPermissionToggle(
                      title: 'Alarm', // Linked to Notification/ExactAlarm
                      permission: _getAlarmPermission(),
                      status: _alarmStatus,
                    ),
                    _buildPermissionToggle(
                      title: 'Notification',
                      permission: Permission.notification,
                      status: _notificationStatus,
                      isNotificationSpecific:
                          true, // Use specific subtitle wording
                    ),

                    // --- Battery (Internal Setting) ---
                    _buildBatterySettingRow(), // This uses its own internal bool state
                    // --- Other Permissions ---
                    _buildPermissionToggle(
                      title: 'Messages (SMS)', // Note iOS limitations
                      permission: Permission.sms,
                      status: _messagesStatus,
                    ),
                    _buildPermissionToggle(
                      title: 'Bluetooth',
                      permission: _getBluetoothPermission(),
                      status: _bluetoothStatus,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  // Helper widget for PERMISSION toggle rows
  Widget _buildPermissionToggle({
    required String title,
    required Permission permission,
    required PermissionStatus status,
    bool isNotificationSpecific =
        false, // Special case for notification description text
  }) {
    // Determine the visual state of the switch
    bool isGrantedOrLimited = status.isGranted || status.isLimited;

    // Determine the subtitle text
    String subtitle;
    if (isNotificationSpecific) {
      subtitle =
          (isGrantedOrLimited)
              ? 'Allowed - App can send notifications'
              : 'Allow app to send you Notification';
    } else {
      subtitle = _getSubtitleForStatus(status, title);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
      ), // Spacing between rows
      child: Row(
        children: [
          Expanded(
            // Allow text to wrap if needed and push switch
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(width: 10), // Add some horizontal space before the switch
          Switch(
            value:
                isGrantedOrLimited, // Visual state reflects if permission is granted/limited
            onChanged: (value) async {
              // Make async for openAppSettings call
              if (isGrantedOrLimited && !value) {
                // Directly open app settings for the user to revoke/change manually
                await openAppSettings();

                // The UI will update automatically when the app resumes via didChangeAppLifecycleState
              } else if (!isGrantedOrLimited && value) {
                // --- User wants to turn ON a denied/restricted/undetermined permission ---
                //rint("User wants to enable $permission.");
                if (status.isPermanentlyDenied || status.isRestricted) {
                  // If permanently denied or restricted, go straight to settings
                  await openAppSettings();
                } else {
                  // Otherwise, request the permission normally
                  _requestPermission(permission);
                }
              }
              // No action needed if the state matches the tap (e.g., tapping OFF when already OFF)
            },
            activeColor: primaryBlue,
            // ignore: deprecated_member_use
            inactiveTrackColor: switchInactiveColor.withOpacity(0.5),
            inactiveThumbColor: switchInactiveColor,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              // Thumb color based on selection state
              if (states.contains(WidgetState.selected)) {
                // selected means 'on' (granted)
                return Colors.white;
              }
              // Default inactive thumb color
              return switchInactiveColor;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              // Track color based on selection state
              if (states.contains(WidgetState.selected)) {
                // selected means 'on' (granted)
                return primaryBlue;
              }
              // Default inactive track color
              // ignore: deprecated_member_use
              return switchInactiveColor.withOpacity(0.5);
            }),
          ),
        ],
      ),
    );
  }

  // Custom widget for the battery setting row (uses internal bool state)
  Widget _buildBatterySettingRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            // Allow text column to take available space before switch
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                // Consider changing this subtitle if the toggle enables the *alert feature*, not battery access permission
                Text(
                  _isBatterySettingEnabled
                      ? 'Alerting Enabled'
                      : 'Alerting Disabled', // Example: More descriptive subtitle
                  // 'Not Allowed', // Original text from image - might be misleading
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                SizedBox(height: 8),
                // Only show the input row if the setting is enabled
                if (_isBatterySettingEnabled)
                  Row(
                    children: [
                      Text(
                        'Generate Alert At:',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 50, // Fixed width for the input box
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: inputBackgroundColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _batteryController,
                            keyboardType: TextInputType.numberWithOptions(
                              signed: false,
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                2,
                              ), // Limit to 2 digits
                              // Optional: Add a formatter to limit range (e.g., 1-99)
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none, // Remove underline
                              isDense: true, // Reduce vertical padding
                              contentPadding:
                                  EdgeInsets.zero, // Adjust content padding
                            ),
                            onChanged: (value) {
                              // Optional: Add validation or state update logic if needed
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '%',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Place the Switch outside the Expanded Column but inside the main Row
          Switch(
            value: _isBatterySettingEnabled, // Uses the internal boolean state
            onChanged: (value) {
              // Simple state toggle for this internal setting
              setState(() => _isBatterySettingEnabled = value);
            },
            activeColor: primaryBlue,
            // ignore: deprecated_member_use
            inactiveTrackColor: switchInactiveColor.withOpacity(0.5),
            inactiveThumbColor: switchInactiveColor,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white; // White thumb when ON
              }
              return switchInactiveColor; // Thumb color when OFF and enabled
            }),
          ),
        ],
      ),
    );
  }
}
