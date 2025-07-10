import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  @JsonKey(name: 'success')
  final bool isSuccess;
  
  @JsonKey(name: 'message')
  final String? message;
  
  @JsonKey(name: 'data')
  final T? data;
  
  @JsonKey(name: 'error')
  final String? error;
  
  @JsonKey(name: 'errors')
  final Map<String, dynamic>? errors;
  
  @JsonKey(name: 'meta')
  final Map<String, dynamic>? meta;
  
  @JsonKey(name: 'timestamp')
  final DateTime? timestamp;
  
  final int? statusCode;
  
  const ApiResponse({
    required this.isSuccess,
    this.message,
    this.data,
    this.error,
    this.errors,
    this.meta,
    this.timestamp,
    this.statusCode,
  });
  
  factory ApiResponse.success({
    T? data,
    String? message,
    Map<String, dynamic>? meta,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      isSuccess: true,
      data: data,
      message: message,
      meta: meta,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }
  
  factory ApiResponse.error(
    String error, {
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      isSuccess: false,
      error: error,
      errors: errors,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic data)? parser,
  }) {
    T? parsedData;
    
    if (json['data'] != null && parser != null) {
      try {
        parsedData = parser(json['data']);
      } catch (e) {
        // If parsing fails, return error response
        return ApiResponse<T>.error(
          'Failed to parse response data: $e',
          statusCode: 500,
        );
      }
    }
    
    return ApiResponse<T>(
      isSuccess: json['success'] ?? false,
      message: json['message'],
      data: parsedData,
      error: json['error'],
      errors: json['errors'],
      meta: json['meta'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return _$ApiResponseToJson(this, toJsonT);
  }
  
  bool get hasData => data != null;
  bool get hasError => error != null || errors != null;
  bool get hasMessage => message != null;
  bool get hasMeta => meta != null;
  
  // Pagination helpers
  int? get currentPage => meta?['current_page'];
  int? get totalPages => meta?['total_pages'];
  int? get totalItems => meta?['total_items'];
  int? get itemsPerPage => meta?['items_per_page'];
  bool get hasNextPage => (currentPage ?? 0) < (totalPages ?? 0);
  bool get hasPreviousPage => (currentPage ?? 0) > 1;
  
  @override
  String toString() {
    return 'ApiResponse(isSuccess: $isSuccess, message: $message, data: $data, error: $error)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponse<T> &&
        other.isSuccess == isSuccess &&
        other.message == message &&
        other.data == data &&
        other.error == error;
  }
  
  @override
  int get hashCode {
    return Object.hash(isSuccess, message, data, error);
  }
}