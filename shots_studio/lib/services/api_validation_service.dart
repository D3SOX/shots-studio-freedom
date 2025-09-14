import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
// http removed for API validation (Gemini disabled)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shots_studio/services/snackbar_service.dart';
import 'package:shots_studio/services/analytics/analytics_service.dart';

class ApiValidationService {
  static final ApiValidationService _instance =
      ApiValidationService._internal();
  factory ApiValidationService() => _instance;
  ApiValidationService._internal();

  static const String _baseUrl = '';
  static const String _apiKeyValidPrefKey = 'api_key_valid';
  static const String _lastValidationTimePrefKey = 'last_validation_time';
  static const Duration _validationCacheDuration = Duration(hours: 24);

  // Cache validation result to avoid repeated API calls
  bool? _cachedValidationResult;
  DateTime? _lastValidationTime;

  /// Validates the API key by sending a simple request to Gemini
  Future<ApiValidationResult> validateApiKey({
    required String apiKey,
    required String modelName,
    required BuildContext context,
    bool showMessages = true,
    bool forceValidation = false,
  }) async {
    // Log analytics for validation attempt
    AnalyticsService().logFeatureUsed('api_key_validation_attempt');

    if (apiKey.isEmpty) {
      // Log analytics for empty API key
      AnalyticsService().logFeatureUsed('api_key_validation_empty');

      if (showMessages) {
        SnackbarService().showError(context, 'API key is required');
      }
      return ApiValidationResult(
        isValid: false,
        error: 'API key is empty',
        shouldRetry: false,
      );
    }

    // Check cache first unless forced validation
    if (!forceValidation && _isCacheValid()) {
      // Log analytics for cache hit
      AnalyticsService().logFeatureUsed('api_key_validation_cache_hit');

      return ApiValidationResult(
        isValid: _cachedValidationResult ?? false,
        fromCache: true,
      );
    }

    // Gemini disabled: treat as invalid without network call
    if (showMessages) {
      SnackbarService().showError(context, 'Cloud AI disabled in this build');
    }

    try {
      final result = ApiValidationResult(
        isValid: false,
        error: 'Cloud AI disabled',
        shouldRetry: false,
      );

      // Cache the result
      await _cacheValidationResult(result.isValid);
      _cachedValidationResult = result.isValid;
      _lastValidationTime = DateTime.now();

      // Log analytics for validation result
      if (result.isValid) {
        AnalyticsService().logFeatureUsed('api_key_validation_success');
      } else {
        AnalyticsService().logFeatureUsed('api_key_validation_failure');
      }

      if (showMessages) {
        SnackbarService().showError(
          context,
          result.error ?? 'Cloud AI disabled',
        );
      }

      return result;
    } catch (e) {
      // Log analytics for validation error
      AnalyticsService().logFeatureUsed('api_key_validation_error');

      if (showMessages) {
        SnackbarService().showError(
          context,
          'Failed to validate API key: ${e.toString()}',
        );
      }
      return ApiValidationResult(
        isValid: false,
        error: 'Validation failed: ${e.toString()}',
        shouldRetry: true,
      );
    }
  }

  /// Performs the actual API validation by sending a simple request
  Future<ApiValidationResult> _performValidation(
    String apiKey,
    String modelName,
  ) async {
    return ApiValidationResult(
      isValid: false,
      error: 'Cloud AI disabled',
      shouldRetry: false,
    );
  }

  /// Checks if the cached validation result is still valid
  bool _isCacheValid() {
    if (_cachedValidationResult == null || _lastValidationTime == null) {
      return false;
    }

    return DateTime.now().difference(_lastValidationTime!) <
        _validationCacheDuration;
  }

  /// Caches the validation result in SharedPreferences
  Future<void> _cacheValidationResult(bool isValid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_apiKeyValidPrefKey, isValid);
      await prefs.setString(
        _lastValidationTimePrefKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Silently fail if caching doesn't work
      debugPrint('Failed to cache API validation result: $e');
    }
  }

  /// Loads cached validation result from SharedPreferences
  Future<void> loadCachedValidationResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedValidationResult = prefs.getBool(_apiKeyValidPrefKey);
      final lastValidationStr = prefs.getString(_lastValidationTimePrefKey);

      if (lastValidationStr != null) {
        _lastValidationTime = DateTime.parse(lastValidationStr);
      }
    } catch (e) {
      // Silently fail if loading doesn't work
      debugPrint('Failed to load cached API validation result: $e');
    }
  }

  /// Clears the cached validation result
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyValidPrefKey);
      await prefs.remove(_lastValidationTimePrefKey);
      _cachedValidationResult = null;
      _lastValidationTime = null;
    } catch (e) {
      debugPrint('Failed to clear API validation cache: $e');
    }
  }

  /// Shows an API key validation dialog when validation fails
  Future<bool> showApiKeyValidationDialog({
    required BuildContext context,
    required String apiKey,
    required String modelName,
    required VoidCallback onConfigureApiKey,
    String? errorMessage,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'API Key Validation Failed',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorMessage ?? 'Your API key is invalid or has expired.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please check your API key and try again, or configure a new one.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current API key: ${apiKey.isNotEmpty ? '${apiKey.substring(0, min(8, apiKey.length))}...' : 'Not set'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfigureApiKey();
                  },
                  child: const Text('Configure API Key'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Quick validation check without showing messages
  Future<bool> isApiKeyValid({
    required String apiKey,
    required String modelName,
    bool forceValidation = false,
  }) async {
    if (apiKey.isEmpty) return false;

    // Always false since cloud AI is disabled
    return false;
  }
}

/// Result of API key validation
class ApiValidationResult {
  final bool isValid;
  final String? error;
  final bool shouldRetry;
  final bool fromCache;

  ApiValidationResult({
    required this.isValid,
    this.error,
    this.shouldRetry = false,
    this.fromCache = false,
  });

  @override
  String toString() {
    return 'ApiValidationResult(isValid: $isValid, error: $error, shouldRetry: $shouldRetry, fromCache: $fromCache)';
  }
}
