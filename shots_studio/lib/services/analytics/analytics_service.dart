// No-op analytics service: preserves API but performs no tracking.

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Initialize analytics
  Future<void> initialize() async {
    // no-op
  }

  bool get analyticsEnabled => false;

  // Enable analytics and telemetry
  Future<void> enableAnalytics() async {
    // no-op
  }

  // Disable analytics and telemetry
  Future<void> disableAnalytics() async {
    // no-op
  }

  // Screenshot Processing Analytics
  Future<void> logBatchProcessingTime(
    int processingTimeMs,
    int screenshotCount,
  ) async {
    // no-op
  }

  Future<void> logAIProcessingSuccess(int screenshotCount) async {
    // no-op
  }

  Future<void> logAIProcessingFailure(String error, int screenshotCount) async {
    // no-op
  }

  // Collection Management
  Future<void> logCollectionCreated() async {
    // no-op
  }

  Future<void> logCollectionDeleted() async {
    // no-op
  }

  Future<void> logCollectionStats(
    int totalCollections,
    int avgScreenshots,
    int minScreenshots,
    int maxScreenshots,
  ) async {
    // no-op
  }

  // User Interaction
  Future<void> logScreenView(String screenName) async {
    // no-op
  }

  Future<void> logFeatureUsed(String featureName) async {
    // no-op
  }

  Future<void> logUserPath(String fromScreen, String toScreen) async {
    // no-op
  }

  // Performance Metrics
  Future<void> logAppStartup() async {
    // no-op
  }

  Future<void> logImageLoadTime(int loadTimeMs, String imageSource) async {
    // no-op
  }

  // Error Tracking
  Future<void> logNetworkError(String error, String context) async {
    // no-op
  }

  // User Engagement
  Future<void> logActiveDay() async {
    // no-op
  }

  Future<void> logFeatureAdopted(String featureName) async {
    // no-op
  }

  Future<void> logReturnUser(int daysSinceLastOpen) async {
    // no-op
  }

  Future<void> logUsageTime(String timeOfDay) async {
    // no-op
  }

  // Search and Discovery
  Future<void> logSearchQuery(String query, int resultsCount) async {
    // no-op
  }

  Future<void> logSearchTimeToResult(int timeMs, bool successful) async {
    // no-op
  }

  Future<void> logSearchSuccess(String query, int timeMs) async {
    // no-op
  }

  // Storage and Resources
  Future<void> logStorageUsage(int totalSizeBytes, int screenshotCount) async {
    // no-op
  }

  Future<void> logBackgroundResourceUsage(
    int processingTimeMs,
    int memoryUsageMB,
  ) async {
    // no-op
  }

  // App Health
  Future<void> logBatteryImpact(String level) async {
    // no-op
  }

  Future<void> logNetworkUsage(int bytesUsed, String operation) async {
    // no-op
  }

  Future<void> logBackgroundTaskCompleted(
    String taskName,
    bool successful,
    int durationMs,
  ) async {
    // no-op
  }

  // Statistics (Very Important)
  Future<void> logTotalScreenshotsProcessed(int count) async {
    // no-op
  }

  Future<void> logTotalCollections(int count) async {
    // no-op
  }

  Future<void> logScreenshotsInCollection(
    int collectionId,
    int screenshotCount,
  ) async {
    // no-op
  }

  Future<void> logScreenshotsAutoCategorized(int count) async {
    // no-op
  }

  Future<void> logReminderSet() async {
    // no-op
  }

  Future<void> logInstallInfo() async {
    // no-op
  }

  Future<void> logInstallSource(String source) async {
    // no-op
  }

  Future<void> logCurrentUsageTime() async {
    // no-op
  }

  // Gemma-specific AI processing analytics
  Future<void> logGemmaProcessingTime({
    required int processingTimeMs,
    required int screenshotCount,
    required int maxParallelAI,
    required String modelName,
    required String devicePlatform,
    required String? deviceModel,
    required bool useCPU,
  }) async {
    // no-op
  }

  // Additional PostHog-specific methods (optional to use)

  /// Identify a user (useful for authenticated users)
  Future<void> identifyUser(
    String userId, [
    Map<String, dynamic>? properties,
  ]) async {
    // no-op
  }

  /// Set person properties for better user analytics
  Future<void> setPersonProperties(Map<String, dynamic> properties) async {
    // no-op
  }

  /// Reset user session (useful for logout)
  Future<void> reset() async {
    // no-op
  }

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String featureKey) async {
    return false;
  }

  /// Alias user (link anonymous user to identified user)
  Future<void> alias(String alias) async {
    // no-op
  }

  /// Group analytics (for organization-level analytics)
  Future<void> group(
    String groupType,
    String groupKey, [
    Map<String, dynamic>? properties,
  ]) async {
    // no-op
  }

  /// Get device information for analytics
  Future<Map<String, String>> getDeviceInfo() async {
    return {'platform': 'unknown', 'model': 'unknown'};
  }
}
