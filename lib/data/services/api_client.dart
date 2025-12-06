import 'package:get/get.dart';
import '../../core/constants/api_endpoints.dart';

/// Base API client using GetConnect for HTTP requests
class ApiClient extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiEndpoints.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);

    // Add default headers
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      // TODO: Add authentication header when implemented
      // request.headers['Authorization'] = 'Bearer $token';
      return request;
    });

    // Add response interceptor for error handling
    httpClient.addResponseModifier((request, response) {
      // Log responses in debug mode
      // print('Response: ${response.statusCode} - ${request.url}');
      return response;
    });

    super.onInit();
  }

  /// Generic GET request
  Future<ApiResponse<T>> getRequest<T>(
    String endpoint, {
    Map<String, String>? query,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await get<dynamic>(endpoint, query: query);
      return _handleResponse(response, decoder);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> postRequest<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await post<dynamic>(endpoint, body);
      return _handleResponse(response, decoder);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> putRequest<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await put<dynamic>(endpoint, body);
      return _handleResponse(response, decoder);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patchRequest<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await patch<dynamic>(endpoint, body);
      return _handleResponse(response, decoder);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> deleteRequest<T>(
    String endpoint, {
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await delete<dynamic>(endpoint);
      return _handleResponse(response, decoder);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic)? decoder,
  ) {
    if (response.isOk && response.body != null) {
      if (decoder != null) {
        return ApiResponse.success(decoder(response.body));
      }
      return ApiResponse.success(response.body as T);
    }

    // Handle error responses
    String errorMessage = 'Unknown error occurred';
    if (response.body != null && response.body is Map) {
      errorMessage =
          response.body['message'] ?? response.body['error'] ?? errorMessage;
    } else if (response.statusText != null) {
      errorMessage = response.statusText!;
    }

    return ApiResponse.error(errorMessage, statusCode: response.statusCode);
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(
      error: message,
      statusCode: statusCode,
      isSuccess: false,
    );
  }
}
