// --- services/api_service.dart ---
// Create a new file: lib/services/api_service.dart
import 'package:flutter/foundation.dart'; // Add this line
import 'dart:convert';
import 'package:connect/models/user_model.dart' show UserModel;
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';
import 'dart:io'; // Add this line

// This is a TOP-LEVEL function, outside of the ApiService class
// It's designed to be run in a separate isolate using compute
List<UserModel> _parseUserModels(String responseBody) {
  final List<dynamic> jsonList = jsonDecode(responseBody);
  return jsonList.map((json) => UserModel.fromJson(json)).toList();
}

// This is a TOP-LEVEL function for parsing a single user model
UserModel _parseUserModel(String responseBody) {
  final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
  return UserModel.fromJson(jsonResponse);
}

class ApiService {
  static const String _baseUrl = 'https://peek.thegwd.ca';

  /// Calls the registration API to generate an OTP.
  /// Returns true if successful, false otherwise.
  static Future<bool> generateOtp({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Assuming your API returns a success message or similar on 200
        print('OTP generation successful: ${response.body}');
        return true;
      } else {
        print(
            'Failed to generate OTP: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error generating OTP: $e');
      return false;
    }
  }

  /// Calls the OTP verification API.
  /// Returns the key string if successful, null otherwise.
  static Future<String?> verifyOtp(
      {required String email, // Assuming email is needed for verification
      required String otp,
      required String username}) async {
    final url = Uri.parse('$_baseUrl/Verify-Otp');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email, // Or username, depending on your API
          'otp': otp,
          'username': username
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Assuming your API returns a JSON object like: {"key": "your_secret_key"}
        final String? key = responseData['token'];
        final String? userName = responseData['username'];
        if (key != null) {
          print('OTP verification successful. Key: $key');
          // save key and email
          await SecureStorageService.saveApiKey(key);
          await SecureStorageService.saveEmail(email);
          if (userName != null) {
            await SecureStorageService.saveUserName(userName);
          }
          return key;
        } else {
          print('OTP verification successful, but key not found in response.');
          return null;
        }
      } else {
        print(
            'Failed to verify OTP: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  static Future<String?> verifyStamp({
    required String email,
    // The 'stamp' passed here is likely intended to be the OTP,
    // not the security stamp/key from storage.
    // Let's rename it to 'otpCode' for clarity if it's the OTP.
    required String otpCode,
  }) async {
    // We need to retrieve the actual security stamp from SecureStorageService
    // because the C# backend's 'Verify-Stamp' endpoint would typically
    // expect a stamp for identity verification or a token.
    // If 'stamp' in the C# code refers to the OTP, then your Dart
    // parameter name 'stamp' is fine, but you still need to await the stored stamp.

    String? storedSecurityStamp = await SecureStorageService.getApiKey();
    String? storedEmail = await SecureStorageService.getEmail();
    String? storedUserName = await SecureStorageService.getUserName();
    String? storedUserId = await SecureStorageService.getUserId();
    // Decide what 'stamp' you want to send in the request body.
    // 1. If the 'stamp' in your C# Verify-Stamp endpoint's request model
    //    is the OTP that the user typed in, then you should send 'otpCode' here.
    // 2. If the 'stamp' in your C# Verify-Stamp endpoint's request model
    //    is a *security stamp/token* that was previously stored, then you should send 'storedSecurityStamp'.

    // Assuming 'stamp' in the C# request body for 'Verify-Stamp' is the
    // security stamp/token you fetched from SecureStorageService.
    // If your C# endpoint's 'stamp' parameter is actually the OTP,
    // then use 'otpCode' below. Let's assume it's the security stamp for now.
    String? stampToSend;
    String? userNameToSend;

    if (storedSecurityStamp != null &&
        storedSecurityStamp.isNotEmpty &&
        storedEmail != null &&
        storedEmail.isNotEmpty &&
        email == storedEmail) {
      stampToSend = storedSecurityStamp;
      userNameToSend = storedUserName;
    } else {
      print(
          'Error: No security stamp found in storage to send for verification.');
      stampToSend = otpCode;

      // Cannot proceed without the stamp
    }

    final url = Uri.parse(
        '$_baseUrl/Verify-Stamp'); // Ensure this matches your C# route (e.g., /api/Controller/Verify-Stamp)

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Potentially add the security stamp to headers as well if your API expects it there
          // 'Authorization': 'Bearer $stampToSend', // Example if it's an auth token
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'stamp': stampToSend,
          'username': userNameToSend!,

          // Use the correctly retrieved stamp value, assert non-null after the check
          // If the C# endpoint expects the OTP here, change 'stampToSend' to 'otpCode'
          // 'otp': otpCode, // If the C# endpoint model has an 'otp' field for the OTP
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Assuming your API returns a JSON object like: {"stamp": "user_stamp_string"}
        // or {"token": "user_token_string"}
        final String? receivedStamp =
            responseData['stamp']; // Or 'token' if it returns a new token/stamp
        final String receivedId = responseData[
            'userid']; // Or 'token' if it returns a new token/stamp
        final String userName = responseData['username'];
        if (receivedStamp != null && receivedStamp.isNotEmpty) {
          print(
              'Stamp verification successful. Received stamp: $receivedStamp');
          // You might want to save this new stamp if it's an updated one
          await SecureStorageService.saveApiKey(receivedStamp);
          await SecureStorageService.saveEmail(email);
          await SecureStorageService.saveUserName(userName);
          await SecureStorageService.saveUserId(receivedId);
          return receivedStamp;
        } else {
          print(
              'Stamp verification successful, but no new stamp found in response.');
          return receivedStamp;
        }
      } else {
        // It's good to log the full response body for debugging 4xx and 5xx errors
        print(
            'Stamp verification failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during stamp verification: $e');
      return null;
    }
  }

  /// Calls the forgot password API.
  /// Returns true if the request was successful, false otherwise.
  static Future<bool> forgotPassword({required String email}) async {
    // IMPORTANT: Replace '/forgotPassword' with your actual API endpoint for forgot password
    final url = Uri.parse('$_baseUrl/forgotPassword');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('Forgot password request successful: ${response.body}');
        return true;
      } else {
        print(
            'Forgot password request failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during forgot password request: $e');
      return false;
    }
  }

  static Future<bool> logout(String email) async {
    final url = Uri.parse('$_baseUrl/logout');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        print('Logged out: ${response.body}');
        return true;
      } else {
        print('Logout failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during logout request: $e');
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    // Construct the full URL for the login endpoint
    final url = Uri.parse(
        '$_baseUrl/login'); // Assuming '/login' is your login endpoint

    try {
      // Make a POST request to the login API
      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json', // Set content type for JSON payload
        },
        body: json.encode({
          'email': email.toLowerCase(), // Send the user's email
          'password': password, // Send the user's password
        }),
      );

      // Check if the request was successful (HTTP status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response body
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the API key and UserName from the successful response
        final String? apiKey =
            responseData['apiKey']; // Assuming the key is 'apiKey'
        final String? userName =
            responseData['username']; // Assuming the key is 'userName'
        final String userId = responseData['userid'];

        // Check if both apiKey and userName are present
        if (apiKey != null &&
            userName != null &&
            apiKey.isNotEmpty &&
            userName.isNotEmpty) {
          await SecureStorageService.saveApiKey(apiKey);
          await SecureStorageService.saveUserName(userName);
          await SecureStorageService.saveUserId(userId);
          await SecureStorageService.saveEmail(email.toLowerCase());
          // TODO: Implement secure storage for the API Key and User Name
          // You should typically store the API key securely (e.g., using shared_preferences
          // or flutter_secure_storage) for subsequent authenticated API calls.
          // Example (uncomment and implement if using shared_preferences):
          // final prefs = await SharedPreferences.getInstance();
          // await prefs.setString('user_api_key', apiKey);
          // await prefs.setString('user_name', userName);

          return true; // Login successful
        } else {
          // If API key or UserName is missing in a successful response
          print(
              'Login successful but missing API Key or User Name in response.');
          return false; // Treat as failure due to incomplete response
        }
      } else {
        // Login failed for other reasons (e.g., invalid credentials, server error)
        print('Login failed: ${response.statusCode} - ${response.body}');
        // You might want to parse response.body here to get specific error messages
        return false; // Login failed
      }
    } catch (e) {
      // Catch any network-related errors (e.g., no internet connection)
      print('Error during login request: $e');
      return false; // Request failed due to exception
    }
  }

  static Future<Map<String, String>> _getHeaders(
      {bool isMultipart = false}) async {
    final String? email = await SecureStorageService.getEmail();
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (email == null || securityStamp == null) {
      throw Exception("User credentials not found for API request.");
    }

    final headers = {
      if (!isMultipart) 'Content-Type': 'application/json',
      'X-User-Email': email,
      'X-Security-Stamp': securityStamp,
    };
    return headers;
  }

  static Future<List<UserModel>> getPeople({
    required int pageNumber,
    required int pageSize,
  }) async {
    final String? email = await SecureStorageService.getEmail();
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (email == null || securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url = Uri.parse('$_baseUrl/get_people');

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'Email': email,
        'SecurityStamp': securityStamp,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // --- Using compute for off-main-isolate JSON parsing ---
        // Pass the response.body to the top-level _parseUserModels function
        // which will run in a separate isolate.
        final List<UserModel> userList =
            await compute(_parseUserModels, response.body);
        return userList;
      } else {
        print(
            'Failed to load people: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load people: ${response.body}');
      }
    } catch (e) {
      print('Error fetching people: $e');
      rethrow;
    }
  }

  // --- NEW: Fetch a single user's profile by ID ---
  static Future<UserModel> getUserProfile(String userId) async {
    final String? email = await SecureStorageService.getEmail();
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (email == null || securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url = Uri.parse('$_baseUrl/get_user_profile/');

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'Email': email,
        'SecurityStamp': securityStamp,
        'UserId': userId,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Use compute for single user profile parsing as well, especially if the profile can be complex
        final UserModel userProfile =
            await compute(_parseUserModel, response.body);
        return userProfile;
      } else {
        print(
            'Failed to load user profile: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  // --- NEW: Update User Profile ---
  static Future<void> updateUserProfile(UserModel updatedProfile) async {
    final String? email = await SecureStorageService.getEmail();
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (email == null || securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url = Uri.parse(
        '$_baseUrl/update_user_profile'); // Your API's update endpoint

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        ...updatedProfile.toMap(), // Convert UserProfile to map
        'Email': email, // Include credentials if needed by update endpoint
        'SecurityStamp': securityStamp,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Successfully updated
        print('Profile updated successfully!');
      } else {
        print(
            'Failed to update profile: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // --- NEW: Upload Image ---
  // This is a generic image upload method. You might need separate
  // endpoints for profile picture vs. other gallery images depending on your backend.
  static Future<String> uploadImage(File imageFile) async {
    final String? email = await SecureStorageService.getEmail();
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (email == null || securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url =
        Uri.parse('$_baseUrl/upload_image'); // Your API's image upload endpoint

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(await _getHeaders(
          isMultipart: true)); // No Content-Type for multipart
      request.fields['Email'] = email; // Add user identification fields
      request.fields['SecurityStamp'] = securityStamp;

      request.files.add(await http.MultipartFile.fromPath(
        'file', // This 'file' key must match what your C# backend expects for the file part
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Assuming your backend returns the URL of the uploaded image
        final String imageUrl =
            jsonResponse['imageUrl']; // Adjust key based on your API response
        return imageUrl;
      } else {
        print(
            'Failed to upload image: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // --- NEW: Delete Image ---
  // If your backend has an endpoint to remove specific images
  static Future<void> deleteImage(String imageUrlToDelete) async {
    final String? email = await SecureStorageService.getEmail();
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (email == null || securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url =
        Uri.parse('$_baseUrl/delete_image'); // Your API's delete image endpoint

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'Email': email,
        'SecurityStamp': securityStamp,
        'ImageUrl': imageUrlToDelete, // The URL of the image to delete
      });

      final response = await http.post(
        url, // Or http.delete if your API uses DELETE for this
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('Image deleted successfully!');
      } else {
        print(
            'Failed to delete image: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete image: ${response.body}');
      }
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }
}
