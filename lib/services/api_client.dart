import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../constans/app_constants.dart';
import 'token_store.dart';

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

  Map<String, String> _buildHeaders({bool includeContentType = true}) {
    final headers = <String, String>{
      if (includeContentType) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
      // X-Authorization
      if (!kIsWeb) {
        headers['X-Authorization'] = 'Bearer $_accessToken';
      }
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

  bool _isRefreshing = false;

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing || _refreshToken == null || _refreshToken!.isEmpty) {
      return false;
    }
    _isRefreshing = true;
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/auth/refresh');
      final res = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': _refreshToken}),
          )
          .timeout(AppConstants.connectTimeout);
      final parsed = _handleResponse(res);
      if (parsed.success && parsed.data is Map && parsed.data['tokens'] is Map) {
        final t = parsed.data['tokens'] as Map;
        final newAccess = (t['access_token'] ?? '').toString();
        final newRefresh = (t['refresh_token'] ?? _refreshToken ?? '').toString();
        if (newAccess.isNotEmpty) {
          setTokens(accessToken: newAccess, refreshToken: newRefresh);
          try {
            await TokenStore.save(newAccess, newRefresh);
          } catch (_) {}
          return true;
        }
      }
    } catch (_) {
    } finally {
      _isRefreshing = false;
    }
    return false;
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

      var res = await http
          .get(uri, headers: _buildHeaders())
          .timeout(AppConstants.connectTimeout);
      if (res.statusCode == 401 && !endpoint.startsWith('/auth/')) {
        if (await _tryRefreshToken()) {
          res = await http
              .get(uri, headers: _buildHeaders())
              .timeout(AppConstants.connectTimeout);
        }
      }
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

  Future<ApiResponseData> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final res = await http
          .put(
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
        errorMessage: 'Gagal memperbarui data: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponseData> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final res = await http
          .delete(uri, headers: _buildHeaders())
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
        errorMessage: 'Gagal menghapus data: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponseData> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileField,
    String? filePath,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final req = http.MultipartRequest('POST', uri);
      req.headers.addAll(_buildHeaders(includeContentType: false));
      if (fields != null) {
        req.fields.addAll(fields);
      }
      if (fileField != null && filePath != null && filePath.isNotEmpty) {
        req.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      }
      final streamed = await req.send().timeout(AppConstants.connectTimeout);
      final res = await http.Response.fromStream(streamed);
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
        errorMessage: 'Gagal mengunggah berkas: $e',
        statusCode: 0,
      );
    }
  }
}