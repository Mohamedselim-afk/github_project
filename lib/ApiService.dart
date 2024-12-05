import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = "https://api.example.com";
  static const Duration timeout = Duration(milliseconds: 30000);

  // Singleton instance of Dio
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: timeout,
    receiveTimeout: timeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Set the token
  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // handle responses
  static dynamic _handleSuccess(Response response) {
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Unexpected Status Code: ${response.statusCode}');
    }
  }

  // GET request
  static Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return _handleSuccess(response); // Process successful response
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<dynamic> post(
      String endpoint, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleSuccess(response); // Process successful response
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<dynamic> put(
      String endpoint, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleSuccess(response); // Process successful response
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<dynamic> delete(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.delete(endpoint, queryParameters: queryParameters);
      return _handleSuccess(response); // Process successful response
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Enhanced Error handling
  static Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;

      if (response != null) {
        final statusCode = response.statusCode ?? 500;
        final message = response.data['message'] ?? 'Something went wrong';

        // Handle specific HTTP status codes
        switch (statusCode) {
          case 400:
            return Exception('Bad Request: $message');
          case 401:
            return Exception('Unauthorized: $message');
          case 403:
            return Exception('Forbidden: $message');
          case 404:
            return Exception('Not Found: $message');
          case 500:
            return Exception('Internal Server Error: $message');
          default:
            return Exception('HTTP Error ($statusCode): $message');
        }
      } else {
        // Handle errors without a response & timeout or no network
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return Exception('Connection Timeout: Unable to connect to the server.');
        } else if (error.type == DioExceptionType.cancel) {
          return Exception('Request Cancelled');
        } else {
          return Exception('Network Error: ${error.message}');
        }
      }
    } else {
      return Exception('Unexpected Error: ${error.toString()}');
    }
  }
}


// Example
void main() async {
  ApiService.setToken('your_jwt_token_here');

  // Example GET request
  try {
    final getResponse = await ApiService.get('/get-example', queryParameters: {'key': 'value'});
    print('GET Response: $getResponse');
  } catch (e) {
    print('GET Error: $e');
  }

  // Example POST request
  try {
    final postData = {'name': 'John', 'age': 30};
    final postResponse = await ApiService.post('/post-example', data: postData);
    print('POST Response: $postResponse');
  } catch (e) {
    print('POST Error: $e');
  }

  // Example PUT request
  try {
    final putData = {'name': 'John Doe', 'age': 31};
    final putResponse = await ApiService.put('/put-example/1', data: putData);
    print('PUT Response: $putResponse');
  } catch (e) {
    print('PUT Error: $e');
  }

  // Example DELETE request
  try {
    final deleteResponse = await ApiService.delete('/delete-example/1');
    print('DELETE Response: $deleteResponse');
  } catch (e) {
    print('DELETE Error: $e');
  }
}
