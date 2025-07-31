// --- services/api_service.dart ---
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:connect/models/user_model.dart' show UserModel;
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';
import 'dart:io';
import 'package:signalr_core/signalr_core.dart'; // Import SignalR Core
import 'dart:async'; // Import for StreamController
import 'package:intl/intl.dart'; // For date formatting if needed, as per user's pubspec.yaml

// Define the Message model here as it's used by the API service
class Message {
  final String id; // The GUID string from the backend
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      // The backend's ChatDto has user1Email and user2Email.
      // We need to decide which one is sender and which is recipient
      // based on the context of the chat history.
      // Assuming 'id' is provided by backend for history, if not, generate.
      id: json['id'] ?? UniqueKey().toString(),
      senderId: json['user1Email'], // Assuming user1Email is the sender
      recipientId: json['user2Email'], // Assuming user2Email is the recipient
      content: json['content'],
      timestamp: DateTime.parse(json['timeStamp']), // Backend uses 'TimeStamp'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// This is a TOP-LEVEL function, outside of the ApiService class
// It's designed to be run in a separate isolate using compute
// This function should be a top-level or static function
List<UserModel> _parseUserModels(String responseBody) {
  final Map<String, dynamic> responseData = json.decode(responseBody);
  // Assuming your API returns a structure like { "users": [...], "totalCount": ... }
  // Adjust this based on your actual API response structure.
  final List<dynamic> usersJson = responseData[
      'users']; // <--- THIS IS THE CRITICAL LINE FOR YOUR "MAP ERROR"

  return usersJson.map((json) => UserModel.fromJson(json)).toList();
}

// This is a TOP-LEVEL function for parsing a single user model
UserModel _parseUserModel(String responseBody) {
  final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
  return UserModel.fromJson(jsonResponse);
}

class ApiService {
  static const String _baseUrl = 'https://peek.thegwd.ca';
  // Base URL for chat specific API endpoints
  static const String _chatBaseUrl = 'https://peek.thegwd.ca';

  static HubConnection? _hubConnection;
  static final StreamController<Message> _messageStreamController =
      StreamController<Message>.broadcast();

  // Stream to listen for new incoming messages
  static Stream<Message> get onNewMessage => _messageStreamController.stream;

  /// Initializes and starts the SignalR connection.
  static Future<void> initializeSignalR() async {
    // Ensure only one connection is active
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      print('SignalR connection already active.');
      return;
    }

    final String? userId = await SecureStorageService.getUserId();
    final String? userEmail = await SecureStorageService.getEmail();

    if (userId == null || userEmail == null) {
      print('SignalR: User not authenticated. Cannot establish connection.');
      return;
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          '$_baseUrl/', // Your SignalR Hub URL
          HttpConnectionOptions(
            accessTokenFactory: () => Future.value(
                userId), // Pass the security stamp as an access token
            logging: (level, message) => print('SignalR Log: $message'),
            // SkipNegotiation: true, // Might be needed for some server configurations
            // Transport: HttpTransportType.WebSockets, // Force WebSockets if needed
          ),
        )
        .build();

    // Register client-side method that the server can call
    _hubConnection!.on('ReceiveMessage', (arguments) {
      print('Received raw message from SignalR: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        // Assuming arguments map directly to ChatDto properties:
        // [Content, user1Email, user2Email, TimeStamp]
        final String content = arguments[0];
        final String user1Email = arguments[1]; // Sender
        final String user2Email = arguments[2]; // Recipient
        final String timestampString = arguments[3];

        try {
          final Message receivedMessage = Message(
            id: UniqueKey()
                .toString(), // Generate a client-side ID if backend doesn't provide one in ChatDto
            senderId: user1Email,
            recipientId: user2Email,
            content: content,
            timestamp: DateTime.parse(timestampString),
          );
          _messageStreamController.add(receivedMessage);
          print(
              'Parsed and added message to stream: ${receivedMessage.content}');
        } catch (e) {
          print('Error parsing received message: $e');
        }
      }
    });

    _hubConnection!.onclose((error) {
      print('SignalR Connection closed: $error');
      // Implement reconnection logic here if necessary
    });

    try {
      await _hubConnection!.start();
      print('SignalR connection started successfully.');
    } catch (e) {
      print('Error starting SignalR connection: $e');
    }
  }

  /// Sends a chat message via SignalR.
  /// Matches the SendMessageDto on the backend.
  static Future<void> sendChatMessage({
    required String senderId,
    required String recipientId,
    required String content,
  }) async {
    if (_hubConnection?.state == HubConnectionState.connected) {
      try {
        // Invoke the server-side method 'SendMessageToUser'
        // Arguments should match your C# SendMessageDto properties:
        // SecurityStamp, SenderEmail, RecipientEmail, Content
        await _hubConnection!.invoke(
          'SendPrivateMessage', // This should be the method name on your SignalR Hub
          args: [recipientId, content],
        );
        print('Message sent via SignalR: $content to $recipientId');
      } catch (e) {
        print('Error sending message via SignalR: $e');
      }
    } else {
      print('SignalR not connected. Message not sent.');
      // Fallback to REST API if SignalR is not connected, or show error
      // await _sendChatMessageViaRest(senderEmail, recipientEmail, content);
    }
  }

  /// Fetches chat history between two users.
  static Future<List<Message>> fetchChatHistory(String user1Id, String user2Id,
      {int count = 50, int offset = 0}) async {
    final String? securityStamp = await SecureStorageService.getApiKey();
    if (securityStamp == null) {
      print('Cannot fetch chat history: Security Stamp not found.');
      return [];
    }

    // Construct the URL based on the provided format
    final uri = Uri.parse(_chatBaseUrl);
    final headers = await _getHeaders();
    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Message.fromJson(json)).toList();
      } else {
        print(
            "Failed to load chat history: ${response.statusCode} ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching chat history: $e");
      return [];
    }
  }

  /// Stops the SignalR connection and closes the message stream.
  static Future<void> stopSignalR() async {
    if (_hubConnection?.state == HubConnectionState.connected) {
      await _hubConnection!.stop();
      print('SignalR connection stopped.');
    }
    if (!_messageStreamController.isClosed) {
      await _messageStreamController.close();
      print('Message stream closed.');
    }
  }

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
        final String? message = responseData['message'];
        if (message != null) {
          return message;
        }
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

  /// Returns the JWT token string if successful, null otherwise.
  static Future<bool> checktoken() async {
    // Construct the full URL for the login endpoint
    final url = Uri.parse(
        '$_baseUrl/validtoken'); // Assuming '/login' is your login endpoint

    final String? jwtToken = await SecureStorageService.getApiKey();
    try {
      // Make a POST request to the login API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Attach the JWT here
        },
        body: json.encode({}),
      );

      // Check if the request was successful (HTTP status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response body
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Catch any network-related errors (e.g., no internet connection)
      print('Error during login request: $e');
      return false; // Request failed due to exception
    }
  }

  /// Handles user login.
  /// Returns the JWT token string if successful, null otherwise.
  static Future<String?> login(String email, String password) async {
    // Construct the full URL for the login endpoint
    final url = Uri.parse(
        '$_baseUrl/login'); // Assuming '/login' is your login endpoint

    try {
      // Make a POST request to the login API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Set content type for JSON payload
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

        // Extract the JWT token from the successful response
        final String? jwtToken =
            responseData['jwtToken']; // Assuming the key is 'token'
        final String? userName = responseData['username'];
        final String? userId = responseData['userid'];

        // Check if the JWT token is present
        if (jwtToken != null && jwtToken.isNotEmpty) {
          // Save the token, username, and user ID securely
          await SecureStorageService.saveApiKey(
              jwtToken); // Save the JWT token as API Key
          if (userName != null) {
            await SecureStorageService.saveUserName(userName);
          }
          if (userId != null) {
            await SecureStorageService.saveUserId(userId);
          }
          await SecureStorageService.saveEmail(email.toLowerCase());

          return jwtToken; // Login successful, return the JWT token
        } else {
          // If JWT token is missing in a successful response
          print('Login successful but missing JWT token in response.');
          return null; // Treat as failure due to incomplete response
        }
      } else {
        // Login failed for other reasons (e.g., invalid credentials, server error)
        print('Login failed: ${response.statusCode} - ${response.body}');
        return null; // Login failed
      }
    } catch (e) {
      // Catch any network-related errors (e.g., no internet connection)
      print('Error during login request: $e');
      return null; // Request failed due to exception
    }
  }

  static Future<Map<String, String>> _getHeaders(
      {bool isMultipart = false}) async {
    String? jwtToken = await SecureStorageService.getApiKey();

    if (jwtToken == null) {
      throw Exception("User credentials not found for API request.");
    }
    final headers = {
      if (!isMultipart) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwtToken', // Attach the JWT here
    };
    return headers;
  }

  static Future<List<UserModel>> getPeople(
      {required int pageNumber,
      required int pageSize,
      String? id,
      String? status,
      int? minAge,
      int? maxAge,
      String? weight,
      String? height,
      String? bodyType,
      String? aboutMe,
      String? lookingFor,
      String? meetAt,
      bool? acceptsNsfwPics,
      int? distance,
      List<String>? genders,
      String? pronouns,
      String? race,
      String? relationshipStatus,
      String? userName,
      String? joined,
      bool? isFresh,
      List<String>? position,
      bool? viewMe}) async {
    final url = Uri.parse('$_baseUrl/get_people');

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        'Id': id,
        'MinAge': minAge,
        'MaxAge': maxAge,
        'weight': weight,
        'height': height,
        'bodyType': bodyType,
        'aboutMe': aboutMe,
        'lookingFor': lookingFor,
        'meetAt': meetAt,
        'acceptsNsfwPics': acceptsNsfwPics,
        'distance': distance,
        'genders': genders,
        'pronouns': pronouns,
        'race': race,
        'relationshipStatus': relationshipStatus,
        'userName': userName,
        'joined': joined,
        'isFresh': isFresh,
        'position': position,
        'viewMe': viewMe
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print(body);
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

  static Future<List<UserModel>> getWhoViewMe(
      {required int pageNumber, required int pageSize}) async {
    final url = Uri.parse('$_baseUrl/get_viewedme');

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print(body);
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

  static Future<List<UserModel>> getWhoTappedMe(
      {required int pageNumber, required int pageSize}) async {
    final url = Uri.parse('$_baseUrl/get_tappedme');

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print(body);
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

  static Future<bool> sendTap(String? id) async {
    final String? apiToken = await SecureStorageService.getApiKey();
    if (apiToken == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }
    final url = Uri.parse('$_baseUrl/get_tapped/');
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'Id': id,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        // Use compute for single user profile parsing as well, especially if the profile can be complex
        return true;
      } else {
        print(
            'Failed to load user profile: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return false;
    }
  }

  // --- NEW: Fetch a single user's profile by ID ---
  static Future<UserModel> getUserProfileById(String? userId) async {
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url = Uri.parse('$_baseUrl/get_user_profile/');

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
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

// --- NEW: Update User Profile ---
  static Future<void> updateExistingUserProfile(
      UserModel updatedProfile) async {
    final url = Uri.parse(
        '$_baseUrl/update_existing_user_profile'); // Your API's update endpoint

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        ...updatedProfile.toMap(), // Convert UserProfile to map
      });
      print(body);
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Successfully updated
        print('Profile updated successfully!');
        return;
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
    final String? securityStamp = await SecureStorageService.getApiKey();

    if (securityStamp == null) {
      throw Exception(
          "Authentication required: Email or Security Stamp not found.");
    }

    final url =
        Uri.parse('$_baseUrl/upload_image'); // Your API's image upload endpoint

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(await _getHeaders(
          isMultipart: true)); // No Content-Type for multipart

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
    final url =
        Uri.parse('$_baseUrl/delete_image'); // Your API's delete image endpoint

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
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

  // report user section
  // --- NEW: Update User Profile ---
  static Future<void> reportUser(String? userId, String? complaint) async {
    final url =
        Uri.parse('$_baseUrl/report_user'); // Your API's update endpoint

    try {
      final headers = await _getHeaders();

      final body = json.encode({"userId": userId, "complaint": complaint});
      //final body = jsonEncode({"userId": userId, "complaint": complaint});
      print(body);
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        // Successfully updated
      print(response.body);
      print(response.statusCode);
        print('Complaint Filed');
        return;
      } else {
        print(response.body);
      print(response.statusCode);
        print(
            'Failed to file complaint: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to complain: ${response.body}');
      }
    } catch (e) {
      
      print('Error complaining: $e');
      rethrow;
    }
  }
}
