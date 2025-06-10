// echotrail_frontend\echo_trail\lib\services\auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.9:8000/api/accounts';

  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register/'); // Fixed: Removed /user/
    print("📝 Registering user: $email");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Register Status Code: ${response.statusCode}');
      print('📄 Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        await saveUserName(name);
        print("✅ User registered successfully: $name");
        return true;
      } else {
        print("❌ Registration failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error during registration: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    print("🔑 Attempting login for email: $email");
    final url = Uri.parse('$baseUrl/login/'); // Fixed: Removed /user/
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Login Status Code: ${response.statusCode}');
      print('📄 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📋 Login response data: $data");

        if (data['refresh'] == null || data['access'] == null) {
          print("❌ Missing refresh or access token in response");
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refreshToken', data['refresh']);
        await prefs.setString('accessToken', data['access']);

        // Save user information
        if (data['user'] != null) {
          final user = data['user'];
          if (user['name'] != null) {
            await saveUserName(user['name']);
            print("📛 User name saved: ${user['name']}");
          }
          if (user['email'] != null) {
            await prefs.setString('user_email', user['email']);
          }
          if (user['id'] != null) {
            await prefs.setInt('user_id', user['id']);
          }
        }

        print("✅ Login successful for $email");
        return true;
      } else {
        print("❌ Login failed with status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error during login: $e");
      return false;
    }
  }

  Future<void> fetchAndSaveUserProfile(String token) async {
    print("📇 Fetching user profile");
    try {
      final url = Uri.parse('$baseUrl/profile/'); // Fixed: Removed /user/
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Profile Status Code: ${response.statusCode}');
      print('📄 Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['name'] != null && data['name'].toString().isNotEmpty) {
          await saveUserName(data['name']);
          print("✅ User name saved from profile: ${data['name']}");
        } else {
          print("⚠️ Name not found in profile response");
        }

        // Save other user data
        final prefs = await SharedPreferences.getInstance();
        if (data['email'] != null) {
          await prefs.setString('user_email', data['email']);
        }
        if (data['id'] != null) {
          await prefs.setInt('user_id', data['id']);
        }
      } else {
        print("❌ Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
    }
  }

  Future<void> saveUserName(String name) async {
    if (name.isEmpty) {
      print("⚠️ Attempted to save empty name, skipping");
      return;
    }
    print("📛 Saving user name: $name");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    print("📛 Retrieved user name: $name");
    return name;
  }

  Future<String> getUserNameForDashboard() async {
    String? name = await getUserName();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    // If no name is stored, try to fetch from server
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      try {
        await fetchAndSaveUserProfile(token);
        name = await getUserName();
        if (name != null && name.isNotEmpty) {
          return name;
        }
      } catch (e) {
        print("❌ Failed to fetch name for dashboard: $e");
      }
    }

    // Fallback to email or default
    final email = prefs.getString('user_email');
    return email?.split('@')[0] ?? 'User';
  }

  Future<bool> tryAutoLogin() async {
    print("🔄 Attempting auto-login");
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      print("❌ No refresh token found");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'), // Already correct
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      print('📡 Auto-Login Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('accessToken', data['access']);

        // Fetch user profile to ensure we have the name
        await fetchAndSaveUserProfile(data['access']);

        print("✅ Auto-login successful");
        return true;
      } else if (response.statusCode == 401) {
        print("🔄 Refresh token expired, clearing data");
        await prefs.clear();
        return false;
      } else {
        print("❌ Auto-login failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error during auto-login: $e");
      return false;
    }
  }

  Future<void> logout() async {
    print("🚪 Logging out");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}