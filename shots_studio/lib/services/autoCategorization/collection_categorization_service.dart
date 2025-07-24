// Collection Categorization Service used for AutoCategorization
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shots_studio/models/screenshot_model.dart';
import 'package:shots_studio/models/collection_model.dart';
import 'package:shots_studio/services/ai_service.dart';

class CollectionCategorizationService extends AIService {
  CollectionCategorizationService(super.config);

  String _getCategorizationPrompt(
    String collectionName,
    String? collectionDescription,
  ) {
    return """
      You are a screenshot categorization system. You will be given a collection and a list of screenshots with their metadata.
      
      Collection to categorize into:
      - Name: "$collectionName"
      - Description: "${collectionDescription ?? 'No description provided'}"
      
      For each screenshot provided, analyze the title, description, and tags to determine if it fits into this collection.
      Consider the semantic meaning and context, not just exact keyword matches.
      
      Respond strictly in this JSON format:
      {
        "matching_screenshots": ["screenshot_id_1", "screenshot_id_2", ...],
        "reasoning": "Brief explanation of why these screenshots match the collection"
      }
      
      Only include screenshot IDs that genuinely fit the collection's purpose and description.
    """;
  }

  Future<Map<String, dynamic>> _prepareRequestData(
    String collectionName,
    String? collectionDescription,
    List<Screenshot> screenshots,
  ) async {
    // Only process screenshots that have been AI-processed
    final screenshotsToProcess =
        screenshots.where((screenshot) {
          // Only include screenshots that have been processed by AI and have at least some metadata
          return screenshot.aiProcessed == true &&
              (screenshot.title?.isNotEmpty == true ||
                  screenshot.description?.isNotEmpty == true ||
                  screenshot.tags.isNotEmpty);
        }).toList();

    // Convert to generic metadata format
    List<Map<String, String>> screenshotMetadata =
        screenshotsToProcess
            .map(
              (screenshot) => {
                'id': screenshot.id,
                'title': screenshot.title ?? 'No title',
                'description': screenshot.description ?? 'No description',
                'tags': screenshot.tags.join(', '),
              },
            )
            .toList();

    // Use the provider-specific request preparation
    final requestData = prepareCategorizationRequest(
      prompt: _getCategorizationPrompt(collectionName, collectionDescription),
      screenshotMetadata: screenshotMetadata,
    );

    // Fallback to old format if provider doesn't support new format
    return requestData ??
        {
          'contents': [
            {
              'parts': [
                {'text': 'Provider not supported for categorization.'},
              ],
            },
          ],
        };
  }

  Future<Map<String, dynamic>> _makeAPIRequest(
    Map<String, dynamic> requestData,
  ) async {
    // Call the base class method to make the actual API request
    return await makeAPIRequest(requestData);
  }

  List<String> _parseResponse(Map<String, dynamic> response) {
    List<String> matchingScreenshots = [];

    try {
      if (response.containsKey('data')) {
        final String responseText = response['data'];
        final RegExp jsonRegExp = RegExp(r'\{.*\}', dotAll: true);
        final match = jsonRegExp.firstMatch(responseText);

        if (match != null) {
          final parsedResponse = jsonDecode(match.group(0)!);
          if (parsedResponse['matching_screenshots'] is List) {
            matchingScreenshots = List<String>.from(
              parsedResponse['matching_screenshots'],
            );
          }
        }
      }
    } catch (e) {
      print('Error parsing categorization response: $e');
    }

    return matchingScreenshots;
  }

  Future<AIResult<List<String>>> categorizeScreenshots({
    required Collection collection,
    required List<Screenshot> screenshots,
    required BatchProcessedCallback onBatchProcessed,
  }) async {
    reset();

    if (screenshots.isEmpty) {
      return AIResult.success(
        [],
        metadata: {'processedCount': 0, 'totalCount': 0, 'batchResults': []},
      );
    }

    Map<String, dynamic> finalResults = {
      'batchResults': [],
      'statusCode': 200,
      'processedCount': 0,
      'totalCount': screenshots.length,
      'cancelled': false,
      'matchingScreenshots': <String>[],
    };

    // Process in batches
    for (int i = 0; i < screenshots.length; i += config.maxParallel) {
      if (isCancelled) {
        finalResults['cancelled'] = true;
        break;
      }

      int end = min(i + config.maxParallel, screenshots.length);
      List<Screenshot> batch = screenshots.sublist(i, end);

      try {
        if (isCancelled) {
          finalResults['cancelled'] = true;
          onBatchProcessed(batch, {
            'error': 'Categorization cancelled by user',
            'cancelled': true,
          });
          break;
        }

        final requestData = await _prepareRequestData(
          collection.name ?? 'Untitled Collection',
          collection.description,
          batch,
        );
        final result = await _makeAPIRequest(requestData);

        if (isCancelled && result['statusCode'] == 499) {
          finalResults['cancelled'] = true;
          onBatchProcessed(batch, result);
          break;
        }

        (finalResults['batchResults'] as List).add({
          'batch': batch.map((s) => s.id).toList(),
          'result': result,
        });

        if (result.containsKey('error')) {
          onBatchProcessed(batch, result);
        } else {
          finalResults['processedCount'] =
              (finalResults['processedCount'] as int) + batch.length;

          // Parse the categorization result
          final matchingIds = _parseResponse(result);
          (finalResults['matchingScreenshots'] as List<String>).addAll(
            matchingIds,
          );

          onBatchProcessed(batch, result);
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        (finalResults['batchResults'] as List).add({
          'batch': batch.map((s) => s.id).toList(),
          'error': e.toString(),
        });
        onBatchProcessed(batch, {'error': e.toString()});
      }
    }

    if (isCancelled) {
      return AIResult.cancelled();
    }

    final matchingScreenshots = List<String>.from(
      finalResults['matchingScreenshots'] ?? [],
    );

    return AIResult.success(
      matchingScreenshots,
      metadata: {
        'processedCount': finalResults['processedCount'],
        'totalCount': finalResults['totalCount'],
        'batchResults': finalResults['batchResults'],
      },
    );
  }
}
