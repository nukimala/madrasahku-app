import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constans/app_constants.dart';

class ApiResponseData {
  final bool success;
  final dynamic data;
  final String? errorCode;
  final String? errorMessage;
  final int statusCode;

  const ApiResponseData({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
    required this.statusCode,
  });
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
    }
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      // Pertahanan ganda: kirim Authorization standar & X-Authorization
      headers['Authorization'] = 'Bearer $_accessToken';
      headers['X-Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  ApiResponseData _handleResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      jsonBody = null;
    }

    if (jsonBody is Map<String, dynamic>) {
      final success = jsonBody['success'] == true;
      if (success) {
        return ApiResponseData(
          success: true,
          data: jsonBody['data'],
          statusCode: response.statusCode,
        );
      } else {
        final err = jsonBody['error'];
        return ApiResponseData(
          success: false,
          errorCode: err is Map ? err['code']?.toString() : 'ERROR',
          errorMessage: err is Map
              ? err['message']?.toString()
              : 'Terjadi kesalahan sistem.',
          statusCode: response.statusCode,
        );
      }
    }

    return ApiResponseData(
      success: response.statusCode >= 200 && response.statusCode < 300,
      errorMessage: 'Respon server tidak valid (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponseData> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final res = await http
          .get(uri, headers: _buildHeaders())
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(res);
    } on SocketException {
      return const ApiResponseData(
        success: false,
        errorMessage: 'Koneksi internet bermasalah / server offline.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponseData(
        success: false,
        errorMessage: 'Gagal memuat data: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponseData> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final res = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(res);
    } on SocketException {
      return const ApiResponseData(
        success: false,
        errorMessage: 'Koneksi internet bermasalah / server offline.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponseData(
        success: false,
        errorMessage: 'Gagal mengirim data: $e',
        statusCode: 0,
      );
    }
  }
}
