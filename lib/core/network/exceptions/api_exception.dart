enum ApiExceptionType {
  timeout,
  noInternet,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  serverError,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final ApiExceptionType type;
  final int? statusCode;
  final Map<String, dynamic>? details;
  
  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.details,
  });
  
  bool get isRetryable {
    switch (type) {
      case ApiExceptionType.timeout:
      case ApiExceptionType.noInternet:
      case ApiExceptionType.serverError:
        return true;
      default:
        return false;
    }
  }
  
  bool get requiresAuth {
    return type == ApiExceptionType.unauthorized;
  }
  
  @override
  String toString() {
    return 'ApiException(message: $message, type: $type, statusCode: $statusCode)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiException &&
        other.message == message &&
        other.type == type &&
        other.statusCode == statusCode;
  }
  
  @override
  int get hashCode {
    return Object.hash(message, type, statusCode);
  }
}